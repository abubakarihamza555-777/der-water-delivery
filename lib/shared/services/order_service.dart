import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';

class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? deliveryPartnerId;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final String? deliveryAddressId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.deliveryPartnerId,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    this.deliveryAddressId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json, List<OrderItem> items) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      deliveryPartnerId: json['delivery_partner_id'] as String?,
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddressId: json['delivery_address_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: items,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String waterTypeId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.waterTypeId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      waterTypeId: json['water_type_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class OrderService {
  static Future<List<Order>> getCustomerOrders(String customerId) async {
    try {
      final ordersData = await SupabaseService.fetch(
        SupabaseConfig.ordersTable,
        filters: [Filter('customer_id', 'eq', customerId)],
        orderBy: 'created_at desc',
      );

      List<Order> orders = [];
      
      for (final orderData in ordersData) {
        final itemsData = await SupabaseService.fetch(
          SupabaseConfig.orderItemsTable,
          filters: [Filter('order_id', 'eq', orderData['id'])],
        );
        
        final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
        orders.add(Order.fromJson(orderData, items));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  static Future<List<Order>> getDeliveryPartnerOrders(String deliveryPartnerId) async {
    try {
      final ordersData = await SupabaseService.fetch(
        SupabaseConfig.ordersTable,
        filters: [Filter('delivery_partner_id', 'eq', deliveryPartnerId)],
        orderBy: 'created_at desc',
      );

      List<Order> orders = [];
      
      for (final orderData in ordersData) {
        final itemsData = await SupabaseService.fetch(
          SupabaseConfig.orderItemsTable,
          filters: [Filter('order_id', 'eq', orderData['id'])],
        );
        
        final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
        orders.add(Order.fromJson(orderData, items));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch delivery partner orders: $e');
    }
  }

  static Future<List<Order>> getAllOrders() async {
    try {
      final ordersData = await SupabaseService.fetch(
        SupabaseConfig.ordersTable,
        orderBy: 'created_at desc',
      );

      List<Order> orders = [];
      
      for (final orderData in ordersData) {
        final itemsData = await SupabaseService.fetch(
          SupabaseConfig.orderItemsTable,
          filters: [Filter('order_id', 'eq', orderData['id'])],
        );
        
        final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
        orders.add(Order.fromJson(orderData, items));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }

  static Future<Order> createOrder({
    required String customerId,
    required String deliveryAddressId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      // Calculate total amount
      double totalAmount = 0;
      for (final item in items) {
        totalAmount += (item['unit_price'] as num) * (item['quantity'] as int);
      }

      // Create order
      final orderData = {
        'customer_id': customerId,
        'delivery_address_id': deliveryAddressId,
        'status': 'pending',
        'payment_status': 'pending',
        'total_amount': totalAmount,
        'notes': notes,
      };

      final createdOrder = await SupabaseService.insert(
        SupabaseConfig.ordersTable,
        orderData,
      );

      // Create order items
      for (final item in items) {
        final itemData = {
          'order_id': createdOrder['id'],
          'water_type_id': item['water_type_id'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'total_price': (item['unit_price'] as num) * (item['quantity'] as int),
        };

        await SupabaseService.insert(
          SupabaseConfig.orderItemsTable,
          itemData,
        );
      }

      // Fetch complete order with items
      final itemsData = await SupabaseService.fetch(
        SupabaseConfig.orderItemsTable,
        filters: [Filter('order_id', 'eq', createdOrder['id'])],
      );
      
      final orderItems = itemsData.map((item) => OrderItem.fromJson(item)).toList();
      return Order.fromJson(createdOrder, orderItems);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final updatedOrder = await SupabaseService.update(
        SupabaseConfig.ordersTable,
        {'status': status},
        'id',
        orderId,
      );

      final itemsData = await SupabaseService.fetch(
        SupabaseConfig.orderItemsTable,
        filters: [Filter('order_id', 'eq', orderId)],
      );
      
      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
      return Order.fromJson(updatedOrder, items);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  static Future<Order> assignDeliveryPartner(String orderId, String deliveryPartnerId) async {
    try {
      final updatedOrder = await SupabaseService.update(
        SupabaseConfig.ordersTable,
        {
          'delivery_partner_id': deliveryPartnerId,
          'status': 'confirmed',
        },
        'id',
        orderId,
      );

      final itemsData = await SupabaseService.fetch(
        SupabaseConfig.orderItemsTable,
        filters: [Filter('order_id', 'eq', orderId)],
      );
      
      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
      return Order.fromJson(updatedOrder, items);
    } catch (e) {
      throw Exception('Failed to assign delivery partner: $e');
    }
  }

  static Future<Order> getOrderById(String orderId) async {
    try {
      final orderData = await SupabaseService.fetch(
        SupabaseConfig.ordersTable,
        filters: [Filter('id', 'eq', orderId)],
      );

      if (orderData.isEmpty) {
        throw Exception('Order not found');
      }

      final itemsData = await SupabaseService.fetch(
        SupabaseConfig.orderItemsTable,
        filters: [Filter('order_id', 'eq', orderId)],
      );
      
      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
      return Order.fromJson(orderData.first, items);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }
}
