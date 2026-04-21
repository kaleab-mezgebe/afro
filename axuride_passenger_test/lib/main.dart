import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';

// ─── CONFIG — paste your JWT token here ─────────────────────────────────────
const String _kToken = 'PASTE_YOUR_JWT_TOKEN_HERE';

const String _kHubUrl =
    'https://axumite-api.dev.niyatconsultancy.com/hubs/trip';
const String _kApiBase = 'https://axumite-api.dev.niyatconsultancy.com/api';

// Addis Ababa test coordinates
const double _kPickupLat = 9.0300;
const double _kPickupLng = 38.7400;
const double _kDropoffLat = 9.0500;
const double _kDropoffLng = 38.7600;

void main() => runApp(const AxuRidePassengerSimulator());

class AxuRidePassengerSimulator extends StatelessWidget {
  const AxuRidePassengerSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxuRide Passenger Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFD700),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        cardColor: const Color(0xFF1A1A1A),
      ),
      home: const SimulatorPage(),
    );
  }
}

// ─── Log entry ───────────────────────────────────────────────────────────────
class LogEntry {
  final String message;
  final LogType type;
  final DateTime time;

  LogEntry(this.message, this.type) : time = DateTime.now();
}

enum LogType { info, success, error, event, system }

// ─── Main simulator page ─────────────────────────────────────────────────────
class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  HubConnection? _hub;
  final List<LogEntry> _logs = [];
  final ScrollController _scrollCtrl = ScrollController();

  String? _tripId;
  String? _passengerUserId;
  String _tripStatus = 'Idle';
  String? _assignedDriverId;
  bool _hubConnected = false;
  bool _busy = false;

  // Live driver location
  double? _driverLat;
  double? _driverLng;

  @override
  void dispose() {
    _hub?.stop();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Logging ────────────────────────────────────────────────────────────────
  void _log(String msg, [LogType type = LogType.info]) {
    setState(() => _logs.add(LogEntry(msg, type)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Connect to SignalR hub ─────────────────────────────────────────────────
  Future<void> _connectHub() async {
    if (_hubConnected) return;
    setState(() => _busy = true);
    _log('Connecting to SignalR hub...', LogType.system);

    try {
      _hub = HubConnectionBuilder()
          .withUrl(
            _kHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => _kToken,
              transport: HttpTransportType.WebSockets,
              skipNegotiation: true,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // ── Register passenger-side listeners ──────────────────────────────────

      // TripStatusChanged — main lifecycle event
      _hub!.on('TripStatusChanged', (args) {
        final data = _parseArgs(args);
        final status = data['status'] ?? '?';
        final driver = data['driverUserId'] ?? '';
        setState(() {
          _tripStatus = status;
          if (driver.isNotEmpty) _assignedDriverId = driver;
        });
        _log(
          '[TripStatusChanged] Status: $status  Driver: $driver',
          LogType.event,
        );
        _handleStatusChange(status);
      });

      // TripFailed
      _hub!.on('TripFailed', (args) {
        final data = _parseArgs(args);
        final reason = data['reason'] ?? 'Unknown';
        setState(() => _tripStatus = 'Failed');
        _log('[TripFailed] Reason: $reason', LogType.error);
        if (_tripId != null) _leaveTrip();
      });

      // DriverLiveLocation — real-time marker movement
      _hub!.on('DriverLiveLocation', (args) {
        final data = _parseArgs(args);
        final loc = data['location'] as Map<String, dynamic>?;
        if (loc != null) {
          setState(() {
            _driverLat = (loc['latitude'] as num?)?.toDouble();
            _driverLng = (loc['longitude'] as num?)?.toDouble();
          });
          _log(
            '[DriverLiveLocation] lat=${_driverLat?.toStringAsFixed(5)} lng=${_driverLng?.toStringAsFixed(5)}',
            LogType.info,
          );
        }
      });

      // DriverRouteBatch — smooth path rendering
      _hub!.on('DriverRouteBatch', (args) {
        final data = _parseArgs(args);
        final locs = data['locations'] as List? ?? [];
        _log('[DriverRouteBatch] ${locs.length} points received', LogType.info);
      });

      // Connection lifecycle
      _hub!.onclose(({error}) {
        setState(() => _hubConnected = false);
        _log(
          'Hub disconnected${error != null ? ": $error" : ""}',
          LogType.error,
        );
      });

      _hub!.onreconnecting(
        ({error}) => _log(
          'Reconnecting...${error != null ? " $error" : ""}',
          LogType.system,
        ),
      );

      _hub!.onreconnected(({connectionId}) {
        _log('Reconnected (id: $connectionId)', LogType.success);
        // Per docs: must rejoin trip group on reconnect
        if (_tripId != null) _joinTrip(_tripId!);
      });

      await _hub!.start();

      // Extract passenger user ID from connection state
      _passengerUserId = _hub!.connectionId;
      setState(() => _hubConnected = true);
      _log(
        '[Hub] Connected — connectionId: $_passengerUserId',
        LogType.success,
      );
    } catch (e) {
      _log('Hub connection failed: $e', LogType.error);
    } finally {
      setState(() => _busy = false);
    }
  }

  // ── Create trip via HTTP ───────────────────────────────────────────────────
  Future<void> _createTrip() async {
    if (!_hubConnected) {
      _log('Connect to hub first', LogType.error);
      return;
    }
    setState(() {
      _busy = true;
      _tripStatus = 'Creating...';
    });
    _log('POST $_kApiBase/v1/passengertrip/request', LogType.system);

    try {
      final body = jsonEncode({
        'passengerUserId': _passengerUserId ?? '',
        'pickupLocation': {'latitude': _kPickupLat, 'longitude': _kPickupLng},
        'dropoffLocation': {
          'latitude': _kDropoffLat,
          'longitude': _kDropoffLng,
        },
        'tripType': 'Standard',
      });

      final res = await http.post(
        Uri.parse('$_kApiBase/v1/passengertrip/request'),
        headers: {
          'Authorization': 'Bearer $_kToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      _log(
        'HTTP ${res.statusCode}: ${res.body}',
        res.statusCode == 200 || res.statusCode == 201
            ? LogType.success
            : LogType.error,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        // Try common response shapes
        final id =
            data['tripId']?.toString() ??
            data['id']?.toString() ??
            (data['data'] as Map?)?['tripId']?.toString() ??
            (data['data'] as Map?)?['id']?.toString();

        if (id != null) {
          setState(() {
            _tripId = id;
            _tripStatus = 'Requested';
          });
          _log('[SUCCESS] Trip created — ID: $id', LogType.success);
          await _joinTrip(id);
        } else {
          _log('Could not extract tripId from response', LogType.error);
        }
      }
    } catch (e) {
      _log('Create trip error: $e', LogType.error);
    } finally {
      setState(() => _busy = false);
    }
  }

  // ── JoinTrip ───────────────────────────────────────────────────────────────
  Future<void> _joinTrip(String tripId) async {
    try {
      await _hub!.invoke('JoinTrip', args: [tripId]);
      _log('[Hub] Joined trip group: $tripId', LogType.success);
      _log(
        '[System] Listening for TripStatusChanged, DriverLiveLocation, DriverRouteBatch, TripFailed...',
        LogType.system,
      );
    } catch (e) {
      _log('JoinTrip error: $e', LogType.error);
    }
  }

  // ── LeaveTrip ──────────────────────────────────────────────────────────────
  Future<void> _leaveTrip() async {
    if (_tripId == null || _hub == null) return;
    try {
      await _hub!.invoke('LeaveTrip', args: [_tripId]);
      _log('[Hub] Left trip group: $_tripId', LogType.system);
      setState(() {
        _tripId = null;
        _assignedDriverId = null;
        _driverLat = null;
        _driverLng = null;
      });
    } catch (e) {
      _log('LeaveTrip error: $e', LogType.error);
    }
  }

  // ── Handle status transitions ──────────────────────────────────────────────
  void _handleStatusChange(String status) {
    switch (status) {
      case 'Accepted':
        _log('Driver accepted — tracking begins', LogType.success);
        break;
      case 'Started':
        _log('Trip started — en route to destination', LogType.success);
        break;
      case 'Completed':
        _log('Trip completed!', LogType.success);
        _leaveTrip();
        break;
      case 'Cancelled':
        _log('Trip cancelled', LogType.error);
        _leaveTrip();
        break;
    }
  }

  // ── Parse SignalR args ─────────────────────────────────────────────────────
  Map<String, dynamic> _parseArgs(List<Object?>? args) {
    if (args == null || args.isEmpty) return {};
    final first = args[0];
    if (first is Map<String, dynamic>) return first;
    if (first is String) {
      try {
        return jsonDecode(first) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {};
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  Future<void> _reset() async {
    if (_tripId != null) await _leaveTrip();
    await _hub?.stop();
    setState(() {
      _hub = null;
      _hubConnected = false;
      _tripId = null;
      _tripStatus = 'Idle';
      _assignedDriverId = null;
      _driverLat = null;
      _driverLng = null;
      _logs.clear();
    });
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'AxuRide Passenger Simulator',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            tooltip: 'Reset',
            onPressed: _busy ? null : _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status bar ────────────────────────────────────────────────────
          _StatusBar(
            hubConnected: _hubConnected,
            tripStatus: _tripStatus,
            tripId: _tripId,
            driverId: _assignedDriverId,
            driverLat: _driverLat,
            driverLng: _driverLng,
          ),

          // ── Action buttons ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _ActionBtn(
                  label: 'Connect Hub',
                  icon: Icons.wifi,
                  color: const Color(0xFF00C853),
                  enabled: !_hubConnected && !_busy,
                  onTap: _connectHub,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Create Trip',
                  icon: Icons.local_taxi,
                  color: const Color(0xFFFFD700),
                  enabled: _hubConnected && _tripId == null && !_busy,
                  onTap: _createTrip,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Leave Trip',
                  icon: Icons.exit_to_app,
                  color: const Color(0xFFFF5252),
                  enabled: _tripId != null && !_busy,
                  onTap: _leaveTrip,
                ),
              ],
            ),
          ),

          // ── Log console ───────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.terminal,
                          size: 14,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'EVENT LOG',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_logs.length} entries',
                          style: const TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFF1A1A1A)),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No events yet',
                              style: TextStyle(
                                color: Color(0xFF444444),
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(8),
                            itemCount: _logs.length,
                            itemBuilder: (_, i) => _LogLine(entry: _logs[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status bar widget ────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final bool hubConnected;
  final String tripStatus;
  final String? tripId;
  final String? driverId;
  final double? driverLat;
  final double? driverLng;

  const _StatusBar({
    required this.hubConnected,
    required this.tripStatus,
    this.tripId,
    this.driverId,
    this.driverLat,
    this.driverLng,
  });

  Color get _statusColor {
    switch (tripStatus) {
      case 'Requested':
        return const Color(0xFFFFB300);
      case 'Accepted':
        return const Color(0xFF00C853);
      case 'Started':
        return const Color(0xFF2196F3);
      case 'Completed':
        return const Color(0xFF9C27B0);
      case 'Cancelled':
      case 'Failed':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFF666666);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _dot(
                hubConnected
                    ? const Color(0xFF00C853)
                    : const Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                hubConnected ? 'Hub Connected' : 'Hub Disconnected',
                style: TextStyle(
                  color: hubConnected
                      ? const Color(0xFF00C853)
                      : const Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  tripStatus,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (tripId != null) ...[
            const SizedBox(height: 8),
            _infoRow('Trip ID', tripId!),
          ],
          if (driverId != null) ...[
            const SizedBox(height: 4),
            _infoRow('Driver', driverId!),
          ],
          if (driverLat != null && driverLng != null) ...[
            const SizedBox(height: 4),
            _infoRow(
              'Driver Location',
              '${driverLat!.toStringAsFixed(5)}, ${driverLng!.toStringAsFixed(5)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  Widget _infoRow(String label, String value) => Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// ─── Action button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.15) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? color.withOpacity(0.5) : const Color(0xFF2A2A2A),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? color : const Color(0xFF444444),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : const Color(0xFF444444),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Log line ─────────────────────────────────────────────────────────────────
class _LogLine extends StatelessWidget {
  final LogEntry entry;
  const _LogLine({required this.entry});

  Color get _color {
    switch (entry.type) {
      case LogType.success:
        return const Color(0xFF00C853);
      case LogType.error:
        return const Color(0xFFFF5252);
      case LogType.event:
        return const Color(0xFFFFD700);
      case LogType.system:
        return const Color(0xFF888888);
      default:
        return const Color(0xFFCCCCCC);
    }
  }

  String get _prefix {
    switch (entry.type) {
      case LogType.success:
        return '✓';
      case LogType.error:
        return '✗';
      case LogType.event:
        return '◆';
      case LogType.system:
        return '·';
      default:
        return ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = entry.time;
    final ts =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ts,
            style: const TextStyle(
              color: Color(0xFF444444),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Text(_prefix, style: TextStyle(color: _color, fontSize: 11)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: _color,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
