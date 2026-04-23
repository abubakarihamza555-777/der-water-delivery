class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Address? defaultAddress;
  final Map<String, dynamic>? deliveryInfo; // For delivery partners

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.defaultAddress,
    this.deliveryInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      profileImage: json['profileImage'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      defaultAddress: json['defaultAddress'] != null ? Address.fromJson(json['defaultAddress']) : null,
      deliveryInfo: json['deliveryInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'defaultAddress': defaultAddress?.toJson(),
      'deliveryInfo': deliveryInfo,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isVerified,
    bool? isActive,
    Address? defaultAddress,
    Map<String, dynamic>? deliveryInfo,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLogin: lastLogin,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
    );
  }

  bool get isCustomer => role == 'customer';
  bool get isDelivery => role == 'delivery';
  bool get isAdmin => role == 'admin';
}

class Address {
  final String id;
  final String type; // home, office, other
  final String name;
  final String phone;
  final String street;
  final String area;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.type,
    required this.name,
    required this.phone,
    required this.street,
    required this.area,
    required this.city,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      type: json['type'] ?? 'home',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'phone': phone,
      'street': street,
      'area': area,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  String get fullAddress => '$street, $area, $city';
} 
