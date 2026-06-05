class Device {
  final int id;
  final String name;
  final String location;
  final String type;

  Device({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as int,
        name: json['name'] as String,
        location: json['location'] as String,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'type': type,
      };
}
