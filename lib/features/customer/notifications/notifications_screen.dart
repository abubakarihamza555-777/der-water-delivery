import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Orders', 'Promos', 'Updates'];
  
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Order Delivered Successfully',
      message: 'Your order #ORD-12345 has been delivered. Thank you for shopping with us!',
      time: '2 minutes ago',
      type: 'Orders',
      isRead: false,
      icon: Icons.check_circle,
      iconColor: Colors.green,
    ),
    NotificationItem(
      id: '2',
      title: 'Special Offer!',
      message: 'Get 20% off on your next order. Use code: FRESH20',
      time: '1 hour ago',
      type: 'Promos',
      isRead: false,
      icon: Icons.local_offer,
      iconColor: Colors.orange,
    ),
    NotificationItem(
      id: '3',
      title: 'Order Out for Delivery',
      message: 'Your order #ORD-12344 is out for delivery. ETA: 15 minutes',
      time: '3 hours ago',
      type: 'Orders',
      isRead: true,
      icon: Icons.delivery_dining,
      iconColor: AppColors.primary,
    ),
    NotificationItem(
      id: '4',
      title: 'App Update Available',
      message: 'Version 2.0 is now available. Update for new features!',
      time: 'Yesterday',
      type: 'Updates',
      isRead: true,
      icon: Icons.system_update,
      iconColor: Colors.purple,
    ),
    NotificationItem(
      id: '5',
      title: 'Welcome to Water Delivery!',
      message: 'Thank you for joining. Enjoy fresh water delivery!',
      time: '2 days ago',
      type: 'Updates',
      isRead: true,
      icon: Icons.celebration,
      iconColor: AppColors.secondary,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification.isRead = true;
                  }
                });
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Column(
        children: [
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
          
          // Notifications list
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
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
            Icons.notifications_none,
            size: 80,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        // Handle notification tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped: ${notification.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: !notification.isRead
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.greyLight,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    required this.icon,
    required this.iconColor,
  });
} 
