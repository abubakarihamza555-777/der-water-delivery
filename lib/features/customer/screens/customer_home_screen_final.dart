import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/providers/auth_provider.dart';
import 'package:water_delivery_app/shared/providers/cart_provider.dart';
import 'package:water_delivery_app/shared/services/order_service.dart';
import 'package:water_delivery_app/shared/services/product_service.dart';
import 'package:water_delivery_app/shared/models/order_model.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Order> _recentOrders = [];
  List<Product> _bulkProducts = [];
  List<Product> _containerProducts = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final allProducts = await ProductService.getProducts();
      
      _bulkProducts = allProducts.where((p) => p.deliveryType == 'bulk').toList();
      _containerProducts = allProducts.where((p) => p.deliveryType == 'container').toList();

      if (authProvider.currentUser != null) {
        final orders = await OrderService.getCustomerOrders(authProvider.currentUser!.id);
        _recentOrders = orders.take(5).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name.split(' ').first ?? 'John';
    final userLocation = authProvider.currentUser?.defaultAddress?.area ?? 'Mbezi Beach, Dar es Salaam';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    userLocation,
                                    style: const TextStyle(fontSize: 14, color: AppColors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Banner
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/truck.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Clean Water,\nDelivered to You',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Choose Delivery Type
                      const Text(
                        'Choose Delivery Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Delivery Type Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildDeliveryTypeCard(
                              title: 'Bulk Water (Truck)',
                              subtitle: 'For tanks & large deliveries',
                              imagePath: 'assets/images/truck.png',
                              onTap: () => Navigator.pushNamed(context, '/bulk-water-order'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDeliveryTypeCard(
                              title: 'Containers (Dumu & Ndoo)',
                              subtitle: '(10L, 20L)',
                              imagePath: 'assets/images/containers.png',
                              onTap: () => Navigator.pushNamed(context, '/containers-order'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(Icons.repeat, 'Reorder', () {}),
                          _buildQuickAction(Icons.track_changes, 'Track Order', () {
                            if (_recentOrders.isNotEmpty) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.orderTracking,
                                arguments: {'orderId': _recentOrders.first.id},
                              );
                            }
                          }),
                          _buildQuickAction(Icons.shopping_bag, 'My Orders', () {
                            Navigator.pushNamed(context, AppRoutes.orderHistory);
                          }),
                          _buildQuickAction(Icons.calendar_today, 'Schedule', () {
                            _showScheduleDialog();
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Last Order
                      const Text(
                        'Last Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLastOrderCard(_getMockLastOrder()),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDeliveryTypeCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Text and button section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: AppColors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Order Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Order _getMockLastOrder() {
  return Order(
    id: 'mock-order-123',
    orderNumber: 'ORD-20240425-1234',
    customerId: 'customer-1',
    status: OrderStatus.delivered,
    paymentStatus: PaymentStatus.completed,
    subtotal: 25000.0,
    deliveryFee: 5000.0,
    taxAmount: 0.0,
    discountAmount: 0.0,
    totalAmount: 30000.0,
    deliveryType: 'bulk',
    deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    items: [
      OrderItem(
        id: 'item-1',
        orderId: 'mock-order-123',
        productId: 'product-1',
        productName: 'Bulk Water',
        volumeLiters: 1000,
        bottleType: 'tank',
        quantity: 1,
        unitPrice: 25000.0,
        totalPrice: 25000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ],
  );
}

Widget _buildLastOrderCard(Order order) {
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBulk ? Icons.local_shipping : Icons.water_drop,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBulk ? '${order.items.first.volumeLiters} Liters (Truck)' : order.items.first.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivered',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(order.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TZS ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Delivered',
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ),
            ],
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
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _handleBottomNavTap(index);
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

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.orderHistory);
        break;
      case 2:
        if (_recentOrders.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderTracking,
            arguments: {'orderId': _recentOrders.first.id},
          );
        }
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.customerProfile);
        break;
    }
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Delivery'),
        content: const Text('Choose date and time for your delivery'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Unable to load data', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 24),
          CustomButton(text: 'Retry', onPressed: _loadData, width: 150),
        ],
      ),
    );
  }
}
