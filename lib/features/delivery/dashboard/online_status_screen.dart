import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class OnlineStatusScreen extends StatefulWidget {
  const OnlineStatusScreen({super.key});

  @override
  State<OnlineStatusScreen> createState() => _OnlineStatusScreenState();
}

class _OnlineStatusScreenState extends State<OnlineStatusScreen> {
  bool _isOnline = true;
  bool _acceptOrders = true;
  bool _acceptCashOrders = true;
  String _selectedZone = 'Zone A - Kinondoni';
  
  final List<String> _zones = [
    'Zone A - Kinondoni',
    'Zone B - Ilala',
    'Zone C - Temeke',
    'Zone D - Ubungo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Online Status'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Online/Offline toggle card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Status icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 50,
                      color: _isOnline ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isOnline ? 'You are Online' : 'You are Offline',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isOnline ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOnline 
                        ? 'You will receive delivery requests'
                        : 'You will not receive any delivery requests',
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 24),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withOpacity(0.5),
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Accept orders switch
                  SwitchListTile(
                    title: const Text('Accept New Orders'),
                    subtitle: const Text('Automatically receive new delivery requests'),
                    value: _acceptOrders,
                    onChanged: _isOnline ? (value) {
                      setState(() {
                        _acceptOrders = value;
                      });
                    } : null,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const Divider(),
                  
                  // Accept cash orders switch
                  SwitchListTile(
                    title: const Text('Accept Cash on Delivery'),
                    subtitle: const Text('Accept orders with cash payment'),
                    value: _acceptCashOrders,
                    onChanged: _isOnline ? (value) {
                      setState(() {
                        _acceptCashOrders = value;
                      });
                    } : null,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const Divider(),
                  
                  // Zone selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Delivery Zone'),
                    subtitle: Text(_selectedZone),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _isOnline ? () {
                      _showZoneSelector();
                    } : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Schedule card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleRow('Today', '8:00 AM - 8:00 PM', true),
                  _buildScheduleRow('Tomorrow', '8:00 AM - 8:00 PM', false),
                  _buildScheduleRow('Custom Schedule', 'Set working hours', false),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (!_isOnline)
              CustomButton(
                text: 'Go Online',
                onPressed: () {
                  setState(() {
                    _isOnline = true;
                  });
                },
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day, String time, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Active',
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  void _showZoneSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Delivery Zone',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._zones.map((zone) => RadioListTile<String>(
                    title: Text(zone),
                    value: zone,
                    groupValue: _selectedZone,
                    onChanged: (value) {
                      setState(() {
                        _selectedZone = value!;
                      });
                      setStateModal(() {});
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  )),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 
