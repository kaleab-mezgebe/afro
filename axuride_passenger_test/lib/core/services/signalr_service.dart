import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../config/app_config.dart';
import '../../domain/trip_event.dart';

/// Callback types
typedef OnLog =
    void Function(
      String message, {
      bool isRaw,
      bool isDetail,
      bool isError,
      bool isSuccess,
    });
typedef OnTripStatusChanged = void Function(TripStatusChangedEvent event);
typedef OnTripFailed = void Function(TripFailedEvent event);
typedef OnDriverLiveLocation = void Function(DriverLiveLocationEvent event);
typedef OnDriverRouteBatch = void Function(DriverRouteBatchEvent event);
typedef OnConnectionChanged = void Function(bool connected);

/// Wraps the SignalR HubConnection.
/// Responsible for: connect, disconnect, JoinTrip, LeaveTrip, and all event listeners.
class SignalRService {
  HubConnection? _hub;

  // Callbacks — set by the controller
  OnLog? onLog;
  OnTripStatusChanged? onTripStatusChanged;
  OnTripFailed? onTripFailed;
  OnDriverLiveLocation? onDriverLiveLocation;
  OnDriverRouteBatch? onDriverRouteBatch;
  OnConnectionChanged? onConnectionChanged;

  bool get isConnected => _hub?.state == HubConnectionState.Connected;

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connect() async {
    if (isConnected) return;

    _log('Connecting to SignalR hub...');

    _hub = HubConnectionBuilder()
        .withUrl(
          kHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => kToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _registerListeners();

    _hub!.onclose(({error}) {
      onConnectionChanged?.call(false);
      _log('Hub disconnected${error != null ? ": $error" : ""}', isError: true);
    });

    _hub!.onreconnecting(
      ({error}) => _log('Reconnecting...${error != null ? " $error" : ""}'),
    );

    _hub!.onreconnected(({connectionId}) {
      onConnectionChanged?.call(true);
      _log('Reconnected', isSuccess: true);
    });

    await _hub!.start();
    onConnectionChanged?.call(true);

    _log('[Hub] Connected — userId: ${jwtConfig.userId}', isSuccess: true);
    _logDetail('  phone:  ${jwtConfig.phoneNumber}');
    _logDetail('  role:   ${jwtConfig.role}');
    _logDetail('  exp:    ${jwtConfig.expiresAt?.toLocal()}');
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    await _hub?.stop();
    _hub = null;
    onConnectionChanged?.call(false);
  }

  // ── JoinTrip ───────────────────────────────────────────────────────────────
  Future<void> joinTrip(String tripId) async {
    try {
      await _hub!.invoke('JoinTrip', args: [tripId]);
      _log('[Hub] Joined trip group: $tripId', isSuccess: true);
      _log(
        '[System] Listening for TripStatusChanged, DriverLiveLocation, DriverRouteBatch, TripFailed...',
      );
    } catch (e) {
      _log('JoinTrip error: $e', isError: true);
    }
  }

  // ── LeaveTrip ──────────────────────────────────────────────────────────────
  Future<void> leaveTrip(String tripId) async {
    try {
      await _hub!.invoke('LeaveTrip', args: [tripId]);
      _log('[Hub] Left trip group: $tripId');
    } catch (e) {
      _log('LeaveTrip error: $e', isError: true);
    }
  }

  // ── Register all passenger-side listeners ──────────────────────────────────
  void _registerListeners() {
    // TripStatusChanged
    _hub!.on('TripStatusChanged', (args) {
      _logRaw('TripStatusChanged', args);
      final data = _parse(args);
      final event = TripStatusChangedEvent.fromMap(data);
      _logDetail('  ├ tripId:          ${event.tripId}');
      _logDetail('  ├ status:          ${event.status}');
      _logDetail(
        '  ├ driverUserId:    ${event.driverUserId.isEmpty ? "(none)" : event.driverUserId}',
      );
      _logDetail('  └ passengerUserId: ${event.passengerUserId}');
      onTripStatusChanged?.call(event);
    });

    // TripFailed
    _hub!.on('TripFailed', (args) {
      _logRaw('TripFailed', args);
      final data = _parse(args);
      final event = TripFailedEvent.fromMap(data);
      _logDetail('  ├ tripId: ${event.tripId}');
      _logDetail('  └ reason: ${event.reason}');
      onTripFailed?.call(event);
    });

    // DriverLiveLocation
    _hub!.on('DriverLiveLocation', (args) {
      _logRaw('DriverLiveLocation', args);
      final data = _parse(args);
      final event = DriverLiveLocationEvent.fromMap(data);
      _logDetail('  ├ tripId: ${event.tripId}');
      _logDetail('  ├ lat:    ${event.location.latitude.toStringAsFixed(6)}');
      _logDetail('  └ lng:    ${event.location.longitude.toStringAsFixed(6)}');
      onDriverLiveLocation?.call(event);
    });

    // DriverRouteBatch
    _hub!.on('DriverRouteBatch', (args) {
      _logRaw('DriverRouteBatch', args);
      final data = _parse(args);
      final event = DriverRouteBatchEvent.fromMap(data);
      _logDetail('  ├ tripId:       ${event.tripId}');
      _logDetail('  ├ driverUserId: ${event.driverUserId}');
      _logDetail('  └ points:       ${event.locations.length}');
      for (int i = 0; i < event.locations.length && i < 3; i++) {
        final p = event.locations[i];
        _logDetail(
          '     [$i] lat=${p.latitude}  lng=${p.longitude}  ts=${p.timestamp ?? ""}',
        );
      }
      if (event.locations.length > 3) {
        _logDetail('     ... ${event.locations.length - 3} more points');
      }
      onDriverRouteBatch?.call(event);
    });

    // TripAssigned (driver-side but log if received)
    _hub!.on('TripAssigned', (args) {
      _logRaw('TripAssigned', args);
      final data = _parse(args);
      _logDetail('  └ tripId: ${data['tripId'] ?? '?'}');
    });

    // TripCancelled
    _hub!.on('TripCancelled', (args) {
      _logRaw('TripCancelled', args);
      final data = _parse(args);
      _logDetail('  ├ tripId: ${data['tripId'] ?? '?'}');
      _logDetail('  └ reason: ${data['reason'] ?? '?'}');
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _parse(List<Object?>? args) {
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

  void _logRaw(String eventName, List<Object?>? args) {
    _log('◈ [$eventName]', isSuccess: false);
    String raw;
    try {
      raw = const JsonEncoder.withIndent(
        '  ',
      ).convert(args?.length == 1 ? args![0] : args);
    } catch (_) {
      raw = args.toString();
    }
    for (final line in raw.split('\n')) {
      onLog?.call('  $line', isRaw: true);
      debugPrint('[AxuRide RAW]   $line');
    }
  }

  void _log(String msg, {bool isError = false, bool isSuccess = false}) {
    onLog?.call(msg, isError: isError, isSuccess: isSuccess);
    debugPrint('[AxuRide] $msg');
  }

  void _logDetail(String msg) {
    onLog?.call(msg, isDetail: true);
    debugPrint('[AxuRide]$msg');
  }
}
