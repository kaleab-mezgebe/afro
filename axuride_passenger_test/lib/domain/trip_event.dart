/// All SignalR event payloads the passenger side can receive.

class TripStatusChangedEvent {
  final String tripId;
  final String status;
  final String driverUserId;
  final String passengerUserId;

  const TripStatusChangedEvent({
    required this.tripId,
    required this.status,
    required this.driverUserId,
    required this.passengerUserId,
  });

  factory TripStatusChangedEvent.fromMap(Map<String, dynamic> m) =>
      TripStatusChangedEvent(
        tripId: m['tripId']?.toString() ?? '',
        status: m['status']?.toString() ?? '',
        driverUserId: m['driverUserId']?.toString() ?? '',
        passengerUserId: m['passengerUserId']?.toString() ?? '',
      );
}

class TripFailedEvent {
  final String tripId;
  final String reason;

  const TripFailedEvent({required this.tripId, required this.reason});

  factory TripFailedEvent.fromMap(Map<String, dynamic> m) => TripFailedEvent(
    tripId: m['tripId']?.toString() ?? '',
    reason: m['reason']?.toString() ?? 'Unknown',
  );
}

class DriverLocation {
  final double latitude;
  final double longitude;
  final String? timestamp;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory DriverLocation.fromMap(Map<String, dynamic> m) => DriverLocation(
    latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
    timestamp: m['timestamp']?.toString(),
  );
}

class DriverLiveLocationEvent {
  final String tripId;
  final DriverLocation location;

  const DriverLiveLocationEvent({required this.tripId, required this.location});

  factory DriverLiveLocationEvent.fromMap(Map<String, dynamic> m) =>
      DriverLiveLocationEvent(
        tripId: m['tripId']?.toString() ?? '',
        location: DriverLocation.fromMap(
          (m['location'] as Map<String, dynamic>?) ?? {},
        ),
      );
}

class DriverRouteBatchEvent {
  final String tripId;
  final String driverUserId;
  final List<DriverLocation> locations;

  const DriverRouteBatchEvent({
    required this.tripId,
    required this.driverUserId,
    required this.locations,
  });

  factory DriverRouteBatchEvent.fromMap(Map<String, dynamic> m) =>
      DriverRouteBatchEvent(
        tripId: m['tripId']?.toString() ?? '',
        driverUserId: m['driverUserId']?.toString() ?? '',
        locations: ((m['locations'] as List?) ?? [])
            .map((l) => DriverLocation.fromMap(l as Map<String, dynamic>))
            .toList(),
      );
}
