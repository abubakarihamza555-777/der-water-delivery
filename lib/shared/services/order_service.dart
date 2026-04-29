import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/config/supabase_config.dart';
import 'package:water_delivery_app/shared/models/order_model.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

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

        final items =
            itemsData.map((item) => OrderItem.fromJson(item)).toList();
        orders.add(Order.fromJson(orderData, items));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  static Future<List<Order>> getDeliveryPartnerOrders(
      String deliveryPartnerId) async {
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

        final items =
            itemsData.map((item) => OrderItem.fromJson(item)).toList();
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

        final items =
            itemsData.map((item) => OrderItem.fromJson(item)).toList();
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
    required List<CartItem> cartItems,
    required double deliveryFee,
    double taxAmount = 0,
    double discountAmount = 0,
    String? notes,
    DateTime? scheduledFor,
  }) async {
    try {
      double subtotal = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
      double totalAmount = subtotal + deliveryFee + taxAmount - discountAmount;

      final orderData = {
        'customer_id': customerId,
        'delivery_address_id': deliveryAddressId,
        'status': OrderStatus.pending.value,
        'payment_status': PaymentStatus.pending.value,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'tax_amount': taxAmount,
        'discount_amount': discountAmount,
        'total_amount': totalAmount,
        'delivery_type': cartItems.first.product.deliveryType,
        'scheduled_for': scheduledFor?.toIso8601String(),
        'notes': notes,
      };

      final createdOrder = await SupabaseService.insert(
        SupabaseConfig.ordersTable,
        orderData,
      );

      // Create order items
      for (final item in cartItems) {
        final itemData = {
          'order_id': createdOrder['id'],
          'product_id': item.product.id,
          'product_name': item.product.name,
          'volume_liters': item.product.volumeLiters,
          'bottle_type': item.product.bottleType,
          'quantity': item.quantity,
          'unit_price': item.product.effectivePrice,
          'total_price': item.totalPrice,
        };

        await SupabaseService.insert(
          SupabaseConfig.orderItemsTable,
          itemData,
        );
      }

      final itemsData = await SupabaseService.fetch(
        SupabaseConfig.orderItemsTable,
        filters: [Filter('order_id', 'eq', createdOrder['id'])],
      );

      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
      return Order.fromJson(createdOrder, items);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<Order> updateOrderStatus(
      String orderId, OrderStatus status) async {
    try {
      final updateData = {'status': status.value};

      if (status == OrderStatus.confirmed) {
        updateData['confirmed_at'] = DateTime.now().toIso8601String();
      } else if (status == OrderStatus.delivered) {
        updateData['delivered_at'] = DateTime.now().toIso8601String();
      }

      final updatedOrder = await SupabaseService.update(
        SupabaseConfig.ordersTable,
        updateData,
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

  static Future<Order> assignDeliveryPartner(
      String orderId, String deliveryPartnerId) async {
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
