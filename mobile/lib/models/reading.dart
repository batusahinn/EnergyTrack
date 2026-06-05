class Reading {
  final int id;
  final int deviceId;
  final double value;
  final String unit;
  final DateTime timestamp;

  Reading({
    required this.id,
    required this.deviceId,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        id: json['id'] as int,
        deviceId: json['deviceId'] as int,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
