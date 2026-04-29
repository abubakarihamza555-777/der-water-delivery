import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/models/order_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Ongoing', 'Completed'];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    // Mock orders data
    _orders = [
      Order(
        id: '1',
        orderNumber: 'ORD-20240425-1234',
        customerId: 'customer-1',
        status: OrderStatus.outForDelivery,
        paymentStatus: PaymentStatus.completed,
        subtotal: 25000.0,
        deliveryFee: 5000.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 30000.0,
        deliveryType: 'bulk',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        items: [
          OrderItem(
            id: 'item-1',
            orderId: '1',
            productId: 'product-1',
            productName: 'Bulk Water',
            volumeLiters: 1000,
            bottleType: 'tank',
            quantity: 1,
            unitPrice: 25000.0,
            totalPrice: 25000.0,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      Order(
        id: '2',
        orderNumber: 'ORD-20240424-5678',
        customerId: 'customer-1',
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.completed,
        subtotal: 15000.0,
        deliveryFee: 3000.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 18000.0,
        deliveryType: 'container',
        deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          OrderItem(
            id: 'item-2',
            orderId: '2',
            productId: 'product-2',
            productName: 'Dumu 20L',
            volumeLiters: 20,
            bottleType: 'bottle',
            quantity: 3,
            unitPrice: 5000.0,
            totalPrice: 15000.0,
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          ),
        ],
      ),
      Order(
        id: '3',
        orderNumber: 'ORD-20240423-9012',
        customerId: 'customer-1',
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.completed,
        subtotal: 9000.0,
        deliveryFee: 2000.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 11000.0,
        deliveryType: 'container',
        deliveredAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        items: [
          OrderItem(
            id: 'item-3',
            orderId: '3',
            productId: 'product-3',
            productName: 'Ndoo 10L',
            volumeLiters: 10,
            bottleType: 'bottle',
            quantity: 3,
            unitPrice: 3000.0,
            totalPrice: 9000.0,
            createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          ),
        ],
      ),
      Order(
        id: '4',
        orderNumber: 'ORD-20240422-3456',
        customerId: 'customer-1',
        status: OrderStatus.cancelled,
        paymentStatus: PaymentStatus.refunded,
        subtotal: 25000.0,
        deliveryFee: 5000.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 30000.0,
        deliveryType: 'bulk',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        items: [
          OrderItem(
            id: 'item-4',
            orderId: '4',
            productId: 'product-1',
            productName: 'Bulk Water',
            volumeLiters: 1000,
            bottleType: 'tank',
            quantity: 1,
            unitPrice: 25000.0,
            totalPrice: 25000.0,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ];
  }

  List<Order> get _filteredOrders {
    switch (_selectedTab) {
      case 1: // Ongoing
        return _orders.where((order) => 
          order.status == OrderStatus.pending ||
          order.status == OrderStatus.confirmed ||
          order.status == OrderStatus.preparing ||
          order.status == OrderStatus.outForDelivery
        ).toList();
      case 2: // Completed
        return _orders.where((order) => 
          order.status == OrderStatus.delivered
        ).toList();
      default: // All
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _selectedTab == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);
    final productNames = order.items.map((i) => i.productName).join(', ');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber.substring(order.orderNumber.length - 6)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: order.status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product details
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isBulk ? Icons.local_shipping : Icons.water_drop,
                  color: order.status.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBulk ? '${order.items.first.volumeLiters} Liters (Truck)' : productNames,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TZS ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (order.status == OrderStatus.outForDelivery)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.orderTracking,
                      arguments: {'orderId': order.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Track Order',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else if (order.status == OrderStatus.delivered)
                ElevatedButton(
                  onPressed: () {
                    _reorderItems(order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reorder',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subMessage;
    
    switch (_selectedTab) {
      case 1:
        message = 'No ongoing orders';
        subMessage = 'You don\'t have any orders in progress';
        break;
      case 2:
        message = 'No completed orders';
        subMessage = 'You haven\'t completed any orders yet';
        break;
      default:
        message = 'No orders yet';
        subMessage = 'Start ordering to see your orders here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Home', 0),
          _buildBottomNavItem(Icons.shopping_bag, 'Orders', 1),
          _buildBottomNavItem(Icons.track_changes, 'Track', 2),
          _buildBottomNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = index == 1; // Orders tab is selected
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
            break;
          case 1:
            // Already on orders
            break;
          case 2:
            // Navigate to track screen with latest order
            if (_orders.isNotEmpty) {
              Navigator.pushNamed(
                context,
                AppRoutes.orderTracking,
                arguments: {'orderId': _orders.first.id},
              );
            }
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.customerProfile);
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Last 7 days', true),
            _buildFilterOption('Last 30 days', false),
            _buildFilterOption('Last 3 months', false),
            _buildFilterOption('All time', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary),
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(title),
      ],
    );
  }

  void _reorderItems(Order order) {
    // Add items back to cart and navigate to checkout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to cart'),
        duration: Duration(seconds: 2),
      ),
    );
    // In a real app, you would add items to cart here
  }
}
