import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/shared/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userResponse = await SupabaseService.getCurrentUser();
      if (userResponse['success']) {
        setState(() {
          _currentUser = userResponse['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser?.name ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? 'No email',
                    style: const TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.phone ?? 'No phone',
                    style: const TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats cards - will be loaded dynamically
            FutureBuilder(
              future: _loadUserStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStatCard('Total Orders', '...', Icons.shopping_bag),
                        _buildStatCard('Total Spent', '...', Icons.money),
                        _buildStatCard('Active', '...', Icons.local_drink),
                      ],
                    ),
                  );
                }
                
                final stats = snapshot.data ?? {'orders': 0, 'spent': 0, 'active': 0};
                return Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard('Total Orders', '${stats['orders']}', Icons.shopping_bag),
                      _buildStatCard('Total Spent', 'TZS ${stats['spent']}', Icons.money),
                      _buildStatCard('Active', '${stats['active']}', Icons.local_drink),
                    ],
                  ),
                );
              },
            ),
            
            // Menu items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    'My Orders',
                    Icons.shopping_bag_outlined,
                    () {
                      Navigator.pushNamed(context, AppRoutes.orderHistory);
                    },
                  ),
                  _buildMenuItem(
                    'Saved Addresses',
                    Icons.location_on_outlined,
                    () {
                      Navigator.pushNamed(context, AppRoutes.savedAddresses);
                    },
                  ),
                  _buildMenuItem(
                    'Payment Methods',
                    Icons.credit_card,
                    () {},
                  ),
                  _buildMenuItem(
                    'Notifications',
                    Icons.notifications_none,
                    () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                  _buildMenuItem(
                    'Promos & Referrals',
                    Icons.card_giftcard,
                    () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    'Settings',
                    Icons.settings_outlined,
                    () {
                      Navigator.pushNamed(context, AppRoutes.customerSettings);
                    },
                  ),
                  _buildMenuItem(
                    'Help & Support',
                    Icons.help_outline,
                    () {},
                  ),
                  _buildMenuItem(
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () {},
                  ),
                  _buildMenuItem(
                    'Terms of Service',
                    Icons.description_outlined,
                    () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logout button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }

  Future<Map<String, dynamic>> _loadUserStats() async {
    if (_currentUser == null) {
      return {'orders': 0, 'spent': 0, 'active': 0};
    }

    try {
      // Get user orders
      final ordersData = await SupabaseService.fetch(
        'orders',
        filters: [
          Filter('customer_id', 'eq', _currentUser!.id),
        ],
      );

      // Calculate stats
      int totalOrders = ordersData.length;
      double totalSpent = ordersData.fold(0.0, (sum, order) => 
        sum + (order['total_amount'] as num).toDouble());
      int activeOrders = ordersData.where((order) => 
        ['pending', 'confirmed', 'preparing', 'out_for_delivery']
        .contains(order['status'])).length;

      return {
        'orders': totalOrders,
        'spent': totalSpent.toInt(),
        'active': activeOrders,
      };
    } catch (e) {
      return {'orders': 0, 'spent': 0, 'active': 0};
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SupabaseService.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 
