import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import '../core/services/signalr_service.dart';
import '../data/trip_api_service.dart';
import '../domain/trip_event.dart';

enum LogType { info, success, error, event, system, raw, detail }

class LogEntry {
  final String message;
  final LogType type;
  final DateTime time;
  LogEntry(this.message, this.type) : time = DateTime.now();
}

/// Pure state + orchestration — no Flutter widgets.
class SimulatorController extends ChangeNotifier {
  final SignalRService _hub = SignalRService();
  final TripApiService _api = TripApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  final List<LogEntry> logs = [];
  bool hubConnected = false;
  bool busy = false;
  String? tripId;
  String tripStatus = 'Idle';
  String? assignedDriverId;
  double? driverLat;
  double? driverLng;

  SimulatorController() {
    _hub.onLog = _onHubLog;
    _hub.onConnectionChanged = (connected) {
      hubConnected = connected;
      notifyListeners();
    };
    _hub.onTripStatusChanged = _onTripStatusChanged;
    _hub.onTripFailed = _onTripFailed;
    _hub.onDriverLiveLocation = _onDriverLiveLocation;
    _hub.onDriverRouteBatch = _onDriverRouteBatch;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> connectHub() async {
    if (hubConnected || busy) return;
    _setBusy(true);
    try {
      await _hub.connect();
    } catch (e) {
      _log('Hub connection failed: $e', LogType.error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> createTrip() async {
    if (!hubConnected || tripId != null || busy) return;
    _setBusy(true);
    tripStatus = 'Creating...';
    notifyListeners();

    _log('POST $kApiBase/v1/passengertrip/request', LogType.system);
    _log('  passengerUserId:    ${jwtConfig.userId}', LogType.detail);
    _log('  passengerPhone:     ${jwtConfig.phoneNumber}', LogType.detail);
    _log('  pickup:             $kPickupLat, $kPickupLng', LogType.detail);
    _log('  dropoff:            $kDropoffLat, $kDropoffLng', LogType.detail);
    _log('  tripType:           Standard', LogType.detail);

    try {
      final id = await _api.createTrip(
        const TripRequest(
          pickupLat: kPickupLat,
          pickupLng: kPickupLng,
          dropoffLat: kDropoffLat,
          dropoffLng: kDropoffLng,
        ),
      );
      tripId = id;
      tripStatus = 'Requested';
      _log('[SUCCESS] Trip created — ID: $id', LogType.success);
      notifyListeners();
      await _hub.joinTrip(id);
    } catch (e) {
      tripStatus = 'Error';
      _log('Create trip failed: $e', LogType.error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> leaveTrip() async {
    if (tripId == null) return;
    await _hub.leaveTrip(tripId!);
    tripId = null;
    assignedDriverId = null;
    driverLat = null;
    driverLng = null;
    tripStatus = 'Idle';
    notifyListeners();
  }

  Future<void> reset() async {
    if (tripId != null) await leaveTrip();
    await _hub.disconnect();
    logs.clear();
    tripStatus = 'Idle';
    notifyListeners();
  }

  // ── Event handlers ─────────────────────────────────────────────────────────

  void _onTripStatusChanged(TripStatusChangedEvent e) {
    tripStatus = e.status;
    if (e.driverUserId.isNotEmpty) assignedDriverId = e.driverUserId;
    notifyListeners();
    _handleStatus(e.status);
  }

  void _onTripFailed(TripFailedEvent e) {
    tripStatus = 'Failed';
    notifyListeners();
    if (tripId != null) leaveTrip();
  }

  void _onDriverLiveLocation(DriverLiveLocationEvent e) {
    driverLat = e.location.latitude;
    driverLng = e.location.longitude;
    notifyListeners();
  }

  void _onDriverRouteBatch(DriverRouteBatchEvent e) {
    // Route batch received — UI can use e.locations for path drawing
    notifyListeners();
  }

  void _handleStatus(String status) {
    switch (status) {
      case 'Accepted':
        _log('Driver accepted — tracking begins', LogType.success);
        break;
      case 'Started':
        _log('Trip started — en route', LogType.success);
        break;
      case 'Completed':
        _log('Trip completed!', LogType.success);
        leaveTrip();
        break;
      case 'Cancelled':
        _log('Trip cancelled', LogType.error);
        leaveTrip();
        break;
    }
  }

  // ── Logging ────────────────────────────────────────────────────────────────

  void _onHubLog(
    String message, {
    bool isRaw = false,
    bool isDetail = false,
    bool isError = false,
    bool isSuccess = false,
  }) {
    LogType type;
    if (isRaw)
      type = LogType.raw;
    else if (isDetail)
      type = LogType.detail;
    else if (isError)
      type = LogType.error;
    else if (isSuccess)
      type = LogType.success;
    else
      type = LogType.info;
    _log(message, type);
  }

  void _log(String msg, LogType type) {
    final entry = LogEntry(msg, type);
    logs.add(entry);
    final t = entry.time;
    final ts =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}.${t.millisecond.toString().padLeft(3, '0')}';
    debugPrint('[AxuRide $ts] $msg');
    notifyListeners();
  }

  void _setBusy(bool v) {
    busy = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _hub.disconnect();
    super.dispose();
  }
}
