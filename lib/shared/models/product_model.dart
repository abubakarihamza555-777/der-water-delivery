class ProductModel {
  final String id;
  final String name;
  final String category; // bottle, tank
  final String size;
  final int price;
  final String? description;
  final String? imageUrl;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.price,
    this.description,
    this.imageUrl,
    this.stock = 0,
    this.isAvailable = true,
    required this.createdAt,
    this.metadata,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'bottle',
      size: json['size'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      stock: json['stock'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'size': size,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'stock': stock,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isBottle => category == 'bottle';
  bool get isTank => category == 'tank';
  
  String get formattedPrice {
    if (price >= 1000000) {
      return 'TZS ${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return 'TZS ${(price / 1000).toStringAsFixed(0)}K';
    }
    return 'TZS $price';
  }
  
  int get pricePerLiter {
    if (size.contains('Liter')) {
      final liters = int.tryParse(size.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (liters > 0) return price ~/ liters;
    }
    return 0;
  }
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'price': product.price,
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'water_drop',
      productCount: json['productCount'] ?? 0,
    );
  }
} 
