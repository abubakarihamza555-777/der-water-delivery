import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';

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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = [description];
    if (landmark.isNotEmpty) {
      parts.add('Near $landmark');
    }
    return parts.join(', ');
  }
}

class AddressService {
  static Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.addressesTable,
        filters: [Filter('user_id', 'eq', userId)],
        orderBy: 'is_default desc, created_at desc',
      );

      return data.map((item) => Address.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user addresses: $e');
    }
  }

  static Future<Address?> getDefaultAddress(String userId) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.addressesTable,
        filters: [
          Filter('user_id', 'eq', userId),
          Filter('is_default', 'eq', true),
        ],
      );

      if (data.isEmpty) {
        return null;
      }

      return Address.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch default address: $e');
    }
  }

  static Future<Address> getAddressById(String addressId) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.addressesTable,
        filters: [Filter('id', 'eq', addressId)],
      );

      if (data.isEmpty) {
        throw Exception('Address not found');
      }

      return Address.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch address: $e');
    }
  }

  static Future<Address> createAddress({
    required String userId,
    required String type,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    String landmark = '',
    bool isDefault = false,
  }) async {
    try {
      // If setting as default, unset other default addresses
      if (isDefault) {
        await _unsetDefaultAddresses(userId);
      }

      final addressData = {
        'user_id': userId,
        'type': type,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'landmark': landmark,
        'is_default': isDefault,
      };

      final response = await SupabaseService.insert(
        SupabaseConfig.addressesTable,
        addressData,
      );

      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  static Future<Address> updateAddress(String addressId, Map<String, dynamic> data) async {
    try {
      // If setting as default, unset other default addresses
      if (data['is_default'] == true) {
        final address = await getAddressById(addressId);
        await _unsetDefaultAddresses(address.userId);
      }

      final response = await SupabaseService.update(
        SupabaseConfig.addressesTable,
        data,
        'id',
        addressId,
      );

      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  static Future<void> deleteAddress(String addressId) async {
    try {
      await SupabaseService.delete(
        SupabaseConfig.addressesTable,
        'id',
        addressId,
      );
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  static Future<Address> setDefaultAddress(String addressId, String userId) async {
    try {
      // Unset all other default addresses
      await _unsetDefaultAddresses(userId);

      // Set this address as default
      final response = await SupabaseService.update(
        SupabaseConfig.addressesTable,
        {'is_default': true},
        'id',
        addressId,
      );

      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  static Future<void> _unsetDefaultAddresses(String userId) async {
    try {
      // Get all addresses for the user
      final addresses = await getUserAddresses(userId);
      
      // Unset default for all addresses
      for (final address in addresses) {
        if (address.isDefault) {
          await SupabaseService.update(
            SupabaseConfig.addressesTable,
            {'is_default': false},
            'id',
            address.id,
          );
        }
      }
    } catch (e) {
      // Continue even if unsetting fails
      print('Warning: Failed to unset default addresses: $e');
    }
  }

  static Future<List<Address>> getAddressesByType(String userId, String type) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.addressesTable,
        filters: [
          Filter('user_id', 'eq', userId),
          Filter('type', 'eq', type),
        ],
        orderBy: 'is_default desc, created_at desc',
      );

      return data.map((item) => Address.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses by type: $e');
    }
  }

  static Future<bool> isAddressInDeliveryZone(double latitude, double longitude) async {
    try {
      // This would typically involve checking against the zones table
      // For now, we'll return true as a placeholder
      // In a real implementation, you would query the zones table using PostGIS
      
      // Example query (would need to be implemented in SupabaseService):
      // SELECT * FROM zones WHERE ST_Contains(area_boundary, ST_MakePoint(?, ?))
      
      return true;
    } catch (e) {
      throw Exception('Failed to check delivery zone: $e');
    }
  }
}
