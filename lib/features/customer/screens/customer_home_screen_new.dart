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
    final userName = authProvider.currentUser?.name.split(' ').first ?? 'Guest';
    final userLocation = authProvider.currentUser?.defaultAddress?.area ?? 'Mbezi Beach, Dar es Salaam';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Header with location
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $userName',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          userLocation,
                                          style: const TextStyle(fontSize: 13, color: AppColors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Delivery',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Tagline
                        const Text(
                          'Clean Water, Delivered to You',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fast, Safe, Reliable',
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                        const SizedBox(height: 24),
                        // Delivery Type Tiles (Uber style)
                        const Text(
                          'Choose Delivery Type',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDeliveryTypeCard(
                                title: 'Bulk Water (Truck)',
                                subtitle: 'For tanks & large deliveries',
                                icon: Icons.fire_truck,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                                ),
                                onTap: () => _showBulkOrderSheet(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDeliveryTypeCard(
                                title: 'Containers',
                                subtitle: 'Drum & Ndoo (10L, 20L)',
                                icon: Icons.water_drop,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                                ),
                                onTap: () => _showContainerOrderSheet(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
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
                        // Last Order Card (if exists)
                        if (_recentOrders.isNotEmpty)
                          _buildLastOrderCard(_recentOrders.first),
                        const SizedBox(height: 24),
                        // Recent Orders List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Orders',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._recentOrders.take(3).map((order) => _buildOrderCard(order)),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDeliveryTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Order Now →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLastOrderCard(Order order) {
    final productNames = order.items.map((i) => i.productName).join(', ');
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);
    final distance = '2.4 km';
    final duration = '10 min';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last Order',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text('$distance • $duration', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isBulk ? '${order.items.first.volumeLiters} Liters (Truck)' : productNames,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TZS ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.displayName,
                  style: TextStyle(fontSize: 11, color: order.status.color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final productNames = order.items.map((i) => i.productName).join(', ');
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: {'orderId': order.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isBulk ? Icons.fire_truck : Icons.water_drop,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Order #${order.orderNumber.substring(order.orderNumber.length - 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'TZS ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productNames,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 10, color: AppColors.greyLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkOrderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Bulk Water (Truck)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ..._bulkProducts.map((product) => ListTile(
              leading: const Icon(Icons.fire_truck, color: AppColors.primary),
              title: Text('${product.volumeLiters} Liters'),
              subtitle: Text('Price per liter: ${product.formattedPricePerLiter}'),
              trailing: Text(product.formattedPrice),
              onTap: () {
                Navigator.pop(context);
                _addToCart(product);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showContainerOrderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Containers (Drum & Ndoo)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ..._containerProducts.map((product) => ListTile(
              leading: const Icon(Icons.water_drop, color: AppColors.primary),
              title: Text(product.name),
              subtitle: Text('${product.volumeLiters} Liters • ${product.formattedPricePerLiter}'),
              trailing: Text(product.formattedPrice),
              onTap: () {
                Navigator.pop(context);
                _addToCart(product);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    // Add to cart and navigate to cart screen
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(product, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)),
    );
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose date and time for your delivery'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Select Date & Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final authProvider = context.watch<AuthProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authProvider.currentUser?.name ?? 'John Deo',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authProvider.currentUser?.phone ?? '+255 712 345 678',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.location_on, 'My Addresses', () {
                    Navigator.pushNamed(context, AppRoutes.savedAddresses);
                  }),
                  _buildDrawerItem(Icons.payment, 'Payment Methods', () {}),
                  _buildDrawerItem(Icons.schedule, 'Scheduled Deliveries', () {}),
                  _buildDrawerItem(Icons.notifications, 'Notifications', () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  }),
                  _buildDrawerItem(Icons.help, 'Help & Support', () {}),
                  _buildDrawerItem(Icons.info, 'About Us', () {}),
                  const Divider(),
                  _buildDrawerItem(Icons.logout, 'Logout', () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
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
