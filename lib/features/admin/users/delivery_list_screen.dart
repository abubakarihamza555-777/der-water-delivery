import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Online', 'Offline', 'Verified', 'Pending'];
  
  final List<DeliveryPerson> _deliveryPersons = [
    DeliveryPerson(
      id: '1',
      name: 'John Driver',
      email: 'john.driver@example.com',
      phone: '+255 712 345 678',
      totalDeliveries: 245,
      rating: 4.8,
      earnings: 450000,
      status: 'Online',
      isVerified: true,
      vehicleType: 'Motorcycle',
      zone: 'Zone A - Kinondoni',
    ),
    DeliveryPerson(
      id: '2',
      name: 'Jane Rider',
      email: 'jane.rider@example.com',
      phone: '+255 765 432 100',
      totalDeliveries: 189,
      rating: 4.9,
      earnings: 380000,
      status: 'Online',
      isVerified: true,
      vehicleType: 'Motorcycle',
      zone: 'Zone B - Ilala',
    ),
    DeliveryPerson(
      id: '3',
      name: 'Mike Wilson',
      email: 'mike@example.com',
      phone: '+255 698 765 432',
      totalDeliveries: 56,
      rating: 4.5,
      earnings: 120000,
      status: 'Offline',
      isVerified: false,
      vehicleType: 'Bicycle',
      zone: 'Zone C - Temeke',
    ),
  ];

  List<DeliveryPerson> get _filteredList {
    var list = _deliveryPersons;
    
    if (_selectedFilter != 'All') {
      list = list.where((d) => 
        _selectedFilter == 'Online' ? d.status == 'Online' :
        _selectedFilter == 'Offline' ? d.status == 'Offline' :
        _selectedFilter == 'Verified' ? d.isVerified :
        !d.isVerified
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      list = list.where((d) =>
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Partners'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
                hintText: 'Search delivery partners...',
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
          
          // Summary
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard('Total Partners', '${_deliveryPersons.length}', Icons.people),
                _buildSummaryCard('Online', _deliveryPersons.where((d) => d.status == 'Online').length.toString(), Icons.wifi),
                _buildSummaryCard('Avg Rating', '4.7', Icons.star),
              ],
            ),
          ),
          
          // Delivery list
          Expanded(
            child: _filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final driver = _filteredList[index];
                      return _buildDriverCard(driver);
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

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 80, color: AppColors.grey),
          SizedBox(height: 16),
          Text('No delivery partners found'),
        ],
      ),
    );
  }

  Widget _buildDriverCard(DeliveryPerson driver) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.userDetails,
          arguments: {'user': driver, 'role': 'delivery'},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delivery_dining, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (driver.isVerified)
                        const Icon(Icons.verified, size: 14, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(driver.email, style: const TextStyle(fontSize: 12)),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(driver.rating.toString(), style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Text('${driver.totalDeliveries} deliveries', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: driver.status == 'Online'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    driver.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: driver.status == 'Online' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  driver.vehicleType,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryPerson {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalDeliveries;
  final double rating;
  final int earnings;
  final String status;
  final bool isVerified;
  final String vehicleType;
  final String zone;

  DeliveryPerson({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalDeliveries,
    required this.rating,
    required this.earnings,
    required this.status,
    required this.isVerified,
    required this.vehicleType,
    required this.zone,
  });
} 
