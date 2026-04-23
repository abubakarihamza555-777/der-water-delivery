import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];
  
  final List<DeliveryHistory> _deliveries = [
    DeliveryHistory(
      id: 'ORD-12345',
      customerName: 'John Doe',
      deliveryAddress: '123 Main Street, Oysterbay',
      items: '2 x 20L Bottles',
      amount: 12000,
      deliveryFee: 2000,
      date: 'Dec 15, 2024',
      time: '2:30 PM',
      status: 'Completed',
      statusColor: Colors.green,
    ),
    DeliveryHistory(
      id: 'ORD-12344',
      customerName: 'Jane Smith',
      deliveryAddress: '45 Business Park, Kinondoni',
      items: '1 x 1000L Tank',
      amount: 150000,
      deliveryFee: 5000,
      date: 'Dec 14, 2024',
      time: '11:00 AM',
      status: 'Completed',
      statusColor: Colors.green,
    ),
    DeliveryHistory(
      id: 'ORD-12343',
      customerName: 'Robert Johnson',
      deliveryAddress: '78 Beach Road, Msasani',
      items: '3 x 10L Bottles',
      amount: 9000,
      deliveryFee: 2000,
      date: 'Dec 13, 2024',
      time: '4:15 PM',
      status: 'Cancelled',
      statusColor: Colors.red,
    ),
    DeliveryHistory(
      id: 'ORD-12342',
      customerName: 'Sarah Williams',
      deliveryAddress: '12 Garden Avenue, Upanga',
      items: '1 x 20L Bottle',
      amount: 5000,
      deliveryFee: 1500,
      date: 'Dec 12, 2024',
      time: '10:45 AM',
      status: 'Completed',
      statusColor: Colors.green,
    ),
  ];

  List<DeliveryHistory> get _filteredDeliveries {
    if (_selectedFilter == 'All') {
      return _deliveries;
    }
    // Add filter logic based on date ranges
    return _deliveries;
  }

  int get _totalEarnings {
    return _deliveries
        .where((d) => d.status == 'Completed')
        .fold(0, (sum, d) => sum + d.deliveryFee);
  }

  int get _totalDeliveries {
    return _deliveries.where((d) => d.status == 'Completed').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard(
                  'Total Deliveries',
                  '$_totalDeliveries',
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  'Total Earnings',
                  'TZS $_totalEarnings',
                  Icons.money,
                  AppColors.primary,
                ),
              ],
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
          
          // Deliveries list
          Expanded(
            child: _filteredDeliveries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = _filteredDeliveries[index];
                      return _buildDeliveryCard(delivery);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.greyLight,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No delivery history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your completed deliveries will appear here',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryHistory delivery) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.deliveryDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: delivery.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    delivery.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: delivery.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    delivery.customerName,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    delivery.deliveryAddress,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  delivery.items,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'TZS ${delivery.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(delivery.date, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(delivery.time, style: const TextStyle(fontSize: 11)),
                  ],
                ),
                Text(
                  'Earned: TZS ${delivery.deliveryFee}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryHistory {
  final String id;
  final String customerName;
  final String deliveryAddress;
  final String items;
  final int amount;
  final int deliveryFee;
  final String date;
  final String time;
  final String status;
  final Color statusColor;

  DeliveryHistory({
    required this.id,
    required this.customerName,
    required this.deliveryAddress,
    required this.items,
    required this.amount,
    required this.deliveryFee,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
  });
} 
