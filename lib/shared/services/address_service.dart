import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';
import 'package:water_delivery_app/shared/models/address_model.dart';

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
    required String phone,
    String landmark = '',
    bool isDefault = false,
  }) async {
    try {
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
        'phone': phone,
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

  static Future<Address> updateAddress(
      String addressId, Map<String, dynamic> data) async {
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

  static Future<Address> setDefaultAddress(
      String addressId, String userId) async {
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

  static Future<List<Address>> getAddressesByType(
      String userId, String type) async {
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

  static Future<bool> isAddressInDeliveryZone(
      double latitude, double longitude) async {
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
