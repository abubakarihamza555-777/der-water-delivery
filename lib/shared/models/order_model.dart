import 'package:water_delivery_app/shared/models/user_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String? deliveryPartnerId;
  final List<OrderItem> items;
  final Address deliveryAddress;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final int total;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final double? deliveryDistance;
  final String? estimatedDeliveryTime;

  OrderModel({
    required this.id,
    required this.customerId,
    this.deliveryPartnerId,
    required this.items,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.deliveryDistance,
    this.estimatedDeliveryTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      deliveryPartnerId: json['deliveryPartnerId'],
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      deliveryAddress: Address.fromJson(json['deliveryAddress']),
      status: OrderStatusExtension.fromString(json['status'] ?? 'pending'),
      paymentMethod: PaymentMethodExtension.fromString(json['paymentMethod'] ?? 'cash'),
      paymentStatus: PaymentStatusExtension.fromString(json['paymentStatus'] ?? 'pending'),
      subtotal: json['subtotal'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? 0,
      discount: json['discount'] ?? 0,
      total: json['total'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      deliveryDistance: json['deliveryDistance']?.toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'deliveryPartnerId': deliveryPartnerId,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'status': status.value,
      'paymentMethod': paymentMethod.value,
      'paymentStatus': paymentStatus.value,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'deliveryDistance': deliveryDistance,
      'estimatedDeliveryTime': estimatedDeliveryTime,
    };
  }

  bool get isPending => status == OrderStatus.pending;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isOutForDelivery => status == OrderStatus.outForDelivery;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isPaid => paymentStatus == PaymentStatus.completed;
}

class OrderItem {
  final String productId;
  final String name;
  final String size;
  final int quantity;
  final int price;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'size': size,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  int get total => price * quantity;
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cash,
  card,
  mobileMoney,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.mobileMoney:
        return 'mobile_money';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'card':
        return PaymentMethod.card;
      case 'mobile_money':
        return PaymentMethod.mobileMoney;
      default:
        return PaymentMethod.cash;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
} 
