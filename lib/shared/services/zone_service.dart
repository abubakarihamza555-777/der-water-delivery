import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';

class Zone {
  final String id;
  final String name;
  final String? description;
  final double baseDeliveryFee;
  final double feePerKm;
  final bool isActive;
  final int priority;
  final List<String> coverageAreas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Zone({
    required this.id,
    required this.name,
    this.description,
    required this.baseDeliveryFee,
    required this.feePerKm,
    this.isActive = true,
    this.priority = 1,
    this.coverageAreas = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseDeliveryFee: (json['base_delivery_fee'] as num).toDouble(),
      feePerKm: (json['fee_per_km'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      priority: json['priority'] as int? ?? 1,
      coverageAreas: List<String>.from(json['coverage_areas'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_delivery_fee': baseDeliveryFee,
      'fee_per_km': feePerKm,
      'is_active': isActive,
      'priority': priority,
      'coverage_areas': coverageAreas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ZoneService {
  static Future<List<Zone>> getActiveZones() async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.zonesTable,
        filters: [Filter('is_active', 'eq', true)],
        orderBy: 'priority asc, name asc',
      );

      return data.map((item) => Zone.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch active zones: $e');
    }
  }

  static Future<List<Zone>> getAllZones() async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.zonesTable,
        orderBy: 'priority asc, name asc',
      );

      return data.map((item) => Zone.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all zones: $e');
    }
  }

  static Future<Zone?> getZoneForAddress(double latitude, double longitude) async {
    try {
      // This would typically use PostGIS to check if the point is within the zone boundary
      // For now, we'll return the first active zone as a placeholder
      // In a real implementation, you would use:
      // SELECT * FROM zones WHERE ST_Contains(area_boundary, ST_MakePoint(?, ?)) AND is_active = true
      // ORDER BY priority ASC LIMIT 1

      final activeZones = await getActiveZones();
      return activeZones.isNotEmpty ? activeZones.first : null;
    } catch (e) {
      throw Exception('Failed to get zone for address: $e');
    }
  }

  static Future<double> calculateDeliveryFee(String zoneId, double distanceKm) async {
    try {
      final zone = await getZoneById(zoneId);
      
      // Calculate fee: base fee + (distance * fee per km)
      double totalFee = zone.baseDeliveryFee + (distanceKm * zone.feePerKm);
      
      return totalFee;
    } catch (e) {
      throw Exception('Failed to calculate delivery fee: $e');
    }
  }

  static Future<Zone> createZone({
    required String name,
    String? description,
    required double baseDeliveryFee,
    required double feePerKm,
    required List<String> coverageAreas,
    int priority = 1,
  }) async {
    try {
      final zoneData = {
        'name': name,
        'description': description,
        'base_delivery_fee': baseDeliveryFee,
        'fee_per_km': feePerKm,
        'coverage_areas': coverageAreas,
        'priority': priority,
        'is_active': true,
      };

      final response = await SupabaseService.insert(
        SupabaseConfig.zonesTable,
        zoneData,
      );

      return Zone.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create zone: $e');
    }
  }

  static Future<Zone> updateZone(String zoneId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.update(
        SupabaseConfig.zonesTable,
        data,
        'id',
        zoneId,
      );

      return Zone.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update zone: $e');
    }
  }

  static Future<void> deleteZone(String zoneId) async {
    try {
      await SupabaseService.delete(
        SupabaseConfig.zonesTable,
        'id',
        zoneId,
      );
    } catch (e) {
      throw Exception('Failed to delete zone: $e');
    }
  }

  static Future<Zone> getZoneById(String zoneId) async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.zonesTable,
        filters: [Filter('id', 'eq', zoneId)],
      );

      if (data.isEmpty) {
        throw Exception('Zone not found');
      }

      return Zone.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch zone: $e');
    }
  }

  static Future<void> toggleZoneStatus(String zoneId, bool isActive) async {
    try {
      await updateZone(zoneId, {'is_active': isActive});
    } catch (e) {
      throw Exception('Failed to toggle zone status: $e');
    }
  }

  static Future<List<String>> getCoverageAreasForZone(String zoneId) async {
    try {
      final zone = await getZoneById(zoneId);
      return zone.coverageAreas;
    } catch (e) {
      throw Exception('Failed to get coverage areas: $e');
    }
  }

  static Future<bool> isAddressInZone(double latitude, double longitude, String zoneId) async {
    try {
      // This would typically use PostGIS to check if the point is within the zone boundary
      // For now, we'll return true as a placeholder
      // In a real implementation, you would use:
      // SELECT ST_Contains(area_boundary, ST_MakePoint(?, ?)) FROM zones WHERE id = ?
      
      return true;
    } catch (e) {
      throw Exception('Failed to check if address is in zone: $e');
    }
  }

  static Future<List<Zone>> getZonesByPriority() async {
    try {
      final data = await SupabaseService.fetch(
        SupabaseConfig.zonesTable,
        filters: [Filter('is_active', 'eq', true)],
        orderBy: 'priority asc',
      );

      return data.map((item) => Zone.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch zones by priority: $e');
    }
  }
}
