import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Inactive', 'Verified'];
  
  final List<UserData> _customers = [
    UserData(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+255 712 345 678',
      totalOrders: 24,
      totalSpent: 125000,
      status: 'Active',
      isVerified: true,
      joinDate: 'Jan 15, 2024',
    ),
    UserData(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+255 765 432 100',
      totalOrders: 18,
      totalSpent: 89000,
      status: 'Active',
      isVerified: true,
      joinDate: 'Feb 20, 2024',
    ),
    UserData(
      id: '3',
      name: 'Robert Johnson',
      email: 'robert@example.com',
      phone: '+255 698 765 432',
      totalOrders: 5,
      totalSpent: 25000,
      status: 'Inactive',
      isVerified: false,
      joinDate: 'Mar 10, 2024',
    ),
  ];

  List<UserData> get _filteredCustomers {
    var customers = _customers;
    
    if (_selectedFilter != 'All') {
      customers = customers.where((c) => 
        _selectedFilter == 'Active' ? c.status == 'Active' :
        _selectedFilter == 'Inactive' ? c.status == 'Inactive' :
        c.isVerified
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      customers = customers.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.phone.contains(_searchQuery)
      ).toList();
    }
    
    return customers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
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
                hintText: 'Search customers...',
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
                _buildSummaryCard('Total Customers', '${_customers.length}', Icons.people),
                _buildSummaryCard('Active', _customers.where((c) => c.status == 'Active').length.toString(), Icons.check_circle),
                _buildSummaryCard('Total Revenue', 'TZS 239K', Icons.money),
              ],
            ),
          ),
          
          // Customers list
          Expanded(
            child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return _buildCustomerCard(customer);
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
          Icon(Icons.people_outline, size: 80, color: AppColors.grey),
          SizedBox(height: 16),
          Text('No customers found'),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(UserData customer) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.userDetails,
          arguments: {'user': customer, 'role': 'customer'},
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
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (customer.isVerified)
                        const Icon(Icons.verified, size: 14, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(customer.email, style: const TextStyle(fontSize: 12)),
                  Text(customer.phone, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.status == 'Active'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: customer.status == 'Active' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${customer.totalOrders} orders',
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

class UserData {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalOrders;
  final int totalSpent;
  final String status;
  final bool isVerified;
  final String joinDate;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    required this.status,
    required this.isVerified,
    required this.joinDate,
  });
} 
