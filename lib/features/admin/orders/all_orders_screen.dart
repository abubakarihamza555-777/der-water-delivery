import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled'];
  String _searchQuery = '';
  
  final List<AdminOrder> _orders = [
    AdminOrder(
      id: 'ORD-12345',
      customerName: 'John Doe',
      amount: 12000,
      status: 'Delivered',
      statusColor: Colors.green,
      date: 'Dec 22, 2024',
      items: '2 x 20L Bottles',
      deliveryPartner: 'John Driver',
    ),
    AdminOrder(
      id: 'ORD-12346',
      customerName: 'Jane Smith',
      amount: 150000,
      status: 'Processing',
      statusColor: Colors.orange,
      date: 'Dec 22, 2024',
      items: '1 x 1000L Tank',
      deliveryPartner: 'Unassigned',
    ),
    AdminOrder(
      id: 'ORD-12347',
      customerName: 'Robert Johnson',
      amount: 5000,
      status: 'Pending',
      statusColor: Colors.red,
      date: 'Dec 21, 2024',
      items: '1 x 10L Bottle',
      deliveryPartner: 'Unassigned',
    ),
    AdminOrder(
      id: 'ORD-12348',
      customerName: 'Sarah Williams',
      amount: 25000,
      status: 'Out for Delivery',
      statusColor: Colors.blue,
      date: 'Dec 21, 2024',
      items: '2 x 20L Bottles, 1 x 10L Bottle',
      deliveryPartner: 'Jane Rider',
    ),
  ];

  List<AdminOrder> get _filteredOrders {
    var orders = _orders;
    
    if (_selectedFilter != 'All') {
      orders = orders.where((o) => o.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
        o.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        o.customerName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Orders'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by order ID or customer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filters
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => _buildFilterChip(_filters[index]),
                ),
              ),
            ),
          ),
          
          // Orders list
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.grey),
          SizedBox(height: 16),
          Text('No orders found'),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AdminOrder order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.adminOrderDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(fontSize: 11, color: order.statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(order.customerName, style: const TextStyle(fontSize: 13)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(order.date, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(order.items, style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.delivery_dining, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(order.deliveryPartner, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text(
                  'TZS ${order.amount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminOrder {
  final String id;
  final String customerName;
  final int amount;
  final String status;
  final Color statusColor;
  final String date;
  final String items;
  final String deliveryPartner;

  AdminOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.items,
    required this.deliveryPartner,
  });
} 
