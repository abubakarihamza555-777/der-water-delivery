class Product {
  final String id;
  final String name;
  final int volumeLiters;
  final String bottleType; // 'bottle' or 'tank'
  final double price;
  final double? discountPrice;
  final bool isActive;
  final String? imageUrl;
  final String? description;
  final int stockQuantity;
  final int maxOrderQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.volumeLiters,
    required this.bottleType,
    required this.price,
    this.discountPrice,
    this.isActive = true,
    this.imageUrl,
    this.description,
    this.stockQuantity = 0,
    this.maxOrderQuantity = 20,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      volumeLiters: json['volume_liters'] as int,
      bottleType: json['bottle_type'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      isActive: json['is_active'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      maxOrderQuantity: json['max_order_quantity'] as int? ?? 20,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  double get effectivePrice => discountPrice ?? price;
  String get category => bottleType == 'tank' ? 'Water Tanks' : 'Water Bottles';
  String get sizeLabel => '$volumeLiters Liters';
  String get formattedPrice => 'TZS ${effectivePrice.toStringAsFixed(0)}';

  double get pricePerLiter {
    if (volumeLiters > 0) return effectivePrice / volumeLiters;
    return 0;
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.effectivePrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
      'unit_price': product.effectivePrice,
      'total_price': totalPrice,
      'product_name': product.name,
      'volume_liters': product.volumeLiters,
      'bottle_type': product.bottleType,
    };
  }
}
