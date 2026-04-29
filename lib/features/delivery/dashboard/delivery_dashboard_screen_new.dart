import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/providers/auth_provider.dart';
import 'package:water_delivery_app/shared/services/order_service.dart';
import 'package:water_delivery_app/shared/models/order_model.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = true;
  bool _isOnline = true;
  double _todayEarnings = 0;
  int _totalDeliveries = 0;
  double _rating = 4.8;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final orders = await OrderService.getDeliveryPartnerOrders(authProvider.currentUser!.id);
        _activeOrders = orders.where((o) => 
          o.status == OrderStatus.confirmed || o.status == OrderStatus.preparing || o.status == OrderStatus.outForDelivery
        ).toList();
        _completedOrders = orders.where((o) => o.status == OrderStatus.delivered).take(5).toList();
        
        _todayEarnings = orders
            .where((o) => o.status == OrderStatus.delivered && 
                DateFormat('yyyy-MM-dd').format(o.deliveredAt ?? o.updatedAt) == DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .fold(0.0, (sum, o) => sum + o.totalAmount);
        
        _totalDeliveries = orders.where((o) => o.status == OrderStatus.delivered).length;
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name.split(' ').first ?? 'Partner';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('Ready for deliveries?', style: TextStyle(color: AppColors.grey)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.deliveryProfile),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Online Toggle Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(_isOnline ? Icons.wifi : Icons.wifi_off, color: _isOnline ? Colors.green : Colors.red, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isOnline ? 'You are Online' : 'You are Offline',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isOnline ? Colors.green : Colors.red),
                                ),
                                Text(
                                  _isOnline ? 'You will receive delivery requests' : 'Go online to receive orders',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isOnline,
                            onChanged: (value) => setState(() => _isOnline = value),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Today\'s Earnings', 'TZS ${_todayEarnings.toStringAsFixed(0)}', Icons.money, Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Deliveries', '$_totalDeliveries', Icons.delivery_dining, Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Rating', '$_rating ⭐', Icons.star, Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Active Deliveries Section
                    if (_activeOrders.isNotEmpty) ...[
                      const Text(
                        'Active Deliveries',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._activeOrders.map((order) => _buildActiveOrderCard(order)),
                      const SizedBox(height: 24),
                    ],
                    // Recent Deliveries Section
                    const Text(
                      'Recent Deliveries',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_completedOrders.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('No deliveries yet')),
                      )
                    else
                      ..._completedOrders.map((order) => _buildCompletedOrderCard(order)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(Order order) {
    final items = order.items.map((i) => i.productName).join(', ');
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);
    final distance = '2.4 km';
    final eta = '15 min';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.displayName,
                  style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text('$distance • ETA $eta', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isBulk ? Colors.blue.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isBulk ? Icons.fire_truck : Icons.water_drop, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBulk ? 'Bulk Water (${order.items.first.volumeLiters}L)' : items,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order.orderNumber.substring(order.orderNumber.length - 6)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                'TZS ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.activeDelivery, arguments: {'orderId': order.id});
                  },
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.activeDelivery, arguments: {'orderId': order.id});
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedOrderCard(Order order) {
    final items = order.items.map((i) => i.productName).join(', ');
    final isBulk = order.items.any((i) => i.volumeLiters >= 1000);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBulk ? 'Bulk Water (${order.items.first.volumeLiters}L)' : items,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.deliveredAt ?? order.updatedAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            'TZS ${order.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.money_outlined), activeIcon: Icon(Icons.money), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, AppRoutes.earnings);
        if (index == 2) Navigator.pushNamed(context, AppRoutes.deliveryProfile);
      },
    );
  }
}
