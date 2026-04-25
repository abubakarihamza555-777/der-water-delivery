class Address {
  final String id;
  final String userId;
  final String type;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String landmark;
  final bool isDefault;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.landmark = '',
    this.isDefault = false,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      landmark: json['landmark'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get fullAddress {
    final parts = [description];
    if (landmark.isNotEmpty) {
      parts.add('Near $landmark');
    }
    return parts.join(', ');
  }
}
