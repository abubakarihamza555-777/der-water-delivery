class Product {
  final String id;
  final String name;
  final int volumeLiters;
  final String bottleType; // 'bottle' or 'tank'
  final double price;
  final double? discountPrice;
  final double pricePerLiter;
  final String deliveryType; // 'bulk' or 'container'
  final double baseDeliveryFee;
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
    required this.pricePerLiter,
    required this.deliveryType,
    this.baseDeliveryFee = 0,
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
      pricePerLiter: (json['price_per_liter'] as num).toDouble(),
      deliveryType: json['delivery_type'] as String? ?? 'container',
      baseDeliveryFee: (json['base_delivery_fee'] as num?)?.toDouble() ?? 0,
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
  String get category => bottleType == 'tank' ? 'Tank' : 'Bottle';
  String get sizeLabel => '$volumeLiters Liters';
  String get formattedPrice => 'TZS ${effectivePrice.toStringAsFixed(0)}';
  String get formattedPricePerLiter => 'TZS ${pricePerLiter.toStringAsFixed(0)} / L';
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
