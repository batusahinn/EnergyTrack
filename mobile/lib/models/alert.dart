class Alert {
  final int id;
  final int deviceId;
  final String message;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.deviceId,
    required this.message,
    required this.timestamp,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'] as int,
        deviceId: json['deviceId'] as int,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
