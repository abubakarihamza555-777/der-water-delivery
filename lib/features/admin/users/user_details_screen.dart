import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isEditing = false;
  
  // Customer data
  final Map<String, dynamic> _customerData = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+255 712 345 678',
    'status': 'Active',
    'isVerified': true,
    'joinDate': 'Jan 15, 2024',
    'totalOrders': 24,
    'totalSpent': 125000,
  };
  
  // Delivery data
  final Map<String, dynamic> _deliveryData = {
    'name': 'John Driver',
    'email': 'john.driver@example.com',
    'phone': '+255 712 345 678',
    'status': 'Online',
    'isVerified': true,
    'joinDate': 'Jan 10, 2024',
    'totalDeliveries': 245,
    'rating': 4.8,
    'earnings': 450000,
    'vehicleType': 'Motorcycle',
    'zone': 'Zone A - Kinondoni',
  };

  late Map<String, dynamic> _userData;
  late String _userRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _userRole = args?['role'] ?? 'customer';
    _userData = _userRole == 'customer' ? _customerData : _deliveryData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_userRole == 'customer' ? 'Customer Details' : 'Delivery Partner Details'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(),
            const SizedBox(height: 16),
            
            // Personal information
            _buildPersonalInfo(),
            const SizedBox(height: 16),
            
            // Statistics (for customer or delivery)
            _buildStatistics(),
            const SizedBox(height: 16),
            
            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _userRole == 'customer' ? Icons.person : Icons.delivery_dining,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userData['name'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email'],
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 4),
          Text(_userData['phone'], style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userData['status'],
                  style: TextStyle(color: _getStatusColor(), fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              if (_userData['isVerified'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Full Name', _userData['name']),
          _buildInfoRow('Email Address', _userData['email']),
          _buildInfoRow('Phone Number', _userData['phone']),
          _buildInfoRow('Join Date', _userData['joinDate']),
          if (_userRole == 'delivery') ...[
            _buildInfoRow('Vehicle Type', _userData['vehicleType']),
            _buildInfoRow('Assigned Zone', _userData['zone']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.grey)),
          ),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: TextEditingController(text: value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_userRole == 'customer') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Total Orders', _userData['totalOrders'].toString(), Icons.shopping_bag),
                _buildStatItem('Total Spent', 'TZS ${_userData['totalSpent']}', Icons.money),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Total Deliveries', _userData['totalDeliveries'].toString(), Icons.delivery_dining),
                _buildStatItem('Rating', _userData['rating'].toString(), Icons.star),
                _buildStatItem('Earnings', 'TZS ${_userData['earnings']}', Icons.money),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _showSuspendDialog();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(_userData['status'] == 'Active' ? 'Suspend User' : 'Activate User'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'View Orders',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_userData['status'] == 'Active' || _userData['status'] == 'Online') {
      return Colors.green;
    }
    return Colors.red;
  }

  void _showSuspendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to suspend ${_userData['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User suspended')),
              );
            },
            child: const Text('Suspend', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 
