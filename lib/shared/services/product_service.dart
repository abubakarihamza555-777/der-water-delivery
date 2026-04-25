import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

class ProductService {
  static Future<List<Product>> getProducts({bool activeOnly = true}) async {
    try {
      final filters = activeOnly ? [Filter('is_active', 'eq', true)] : null;

      final data = await SupabaseService.fetch(
        'products',
        filters: filters,
        orderBy: 'volume_liters asc',
      );

      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<List<Product>> getBottles() async {
    final allProducts = await getProducts();
    return allProducts.where((p) => p.bottleType == 'bottle').toList();
  }

  static Future<List<Product>> getTanks() async {
    final allProducts = await getProducts();
    return allProducts.where((p) => p.bottleType == 'tank').toList();
  }

  static Future<Product> getProductById(String id) async {
    try {
      final data = await SupabaseService.fetch(
        'products',
        filters: [Filter('id', 'eq', id)],
      );

      if (data.isEmpty) {
        throw Exception('Product not found');
      }

      return Product.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  static Future<bool> checkStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      return product.stockQuantity >= quantity;
    } catch (e) {
      return false;
    }
  }
}
