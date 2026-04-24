import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';

class WaterType {
  final String id;
  final String name;
  final String description;
  final double price;
  final int volumeLiters;
  final String bottleType;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterType({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.volumeLiters,
    required this.bottleType,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WaterType.fromJson(Map<String, dynamic> json) {
    return WaterType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      volumeLiters: json['volume_liters'] as int,
      bottleType: json['bottle_type'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'volume_liters': volumeLiters,
      'bottle_type': bottleType,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get size => '$volumeLiters Liters';
  String get unit => bottleType == 'glass' ? 'tank' : 'bottle';
  String get category => volumeLiters >= 1000 ? 'Tanks' : 'Bottles';
}

class WaterService {
  static Future<List<WaterType>> getWaterTypes({bool activeOnly = true}) async {
    try {
      final filters = activeOnly 
          ? [Filter('is_active', 'eq', true)]
          : null;
      
      final data = await SupabaseService.fetch(
        SupabaseConfig.waterTypesTable,
        filters: filters,
        orderBy: 'name',
      );

      return data.map((item) => WaterType.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch water types: $e');
    }
  }

  static Future<WaterType> getWaterTypeById(String id) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.waterTypesTable,
        filters: [Filter('id', 'eq', id)],
      );

      if (data.isEmpty) {
        throw Exception('Water type not found');
      }

      return WaterType.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch water type: $e');
    }
  }

  static Future<List<WaterType>> getWaterTypesByCategory(String category) async {
    try {
      final allTypes = await getWaterTypes();
      
      if (category == 'Bottles') {
        return allTypes.where((type) => type.volumeLiters < 1000).toList();
      } else if (category == 'Tanks') {
        return allTypes.where((type) => type.volumeLiters >= 1000).toList();
      }
      
      return allTypes;
    } catch (e) {
      throw Exception('Failed to fetch water types by category: $e');
    }
  }

  static Future<WaterType> createWaterType({
    required String name,
    required String description,
    required double price,
    required int volumeLiters,
    required String bottleType,
    String? imageUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'price': price,
        'volume_liters': volumeLiters,
        'bottle_type': bottleType,
        'image_url': imageUrl,
        'is_active': true,
      };

      final response = await SupabaseService.insert(
        SupabaseConfig.waterTypesTable,
        data,
      );

      return WaterType.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create water type: $e');
    }
  }

  static Future<WaterType> updateWaterType(String id, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.update(
        SupabaseConfig.waterTypesTable,
        data,
        'id',
        id,
      );

      return WaterType.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update water type: $e');
    }
  }

  static Future<void> deleteWaterType(String id) async {
    try {
      await SupabaseService.delete(
        SupabaseConfig.waterTypesTable,
        'id',
        id,
      );
    } catch (e) {
      throw Exception('Failed to delete water type: $e');
    }
  }

  static Future<void> toggleWaterTypeStatus(String id, bool isActive) async {
    try {
      await updateWaterType(id, {'is_active': isActive});
    } catch (e) {
      throw Exception('Failed to toggle water type status: $e');
    }
  }
}
