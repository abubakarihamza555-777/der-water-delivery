import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 350,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 60,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live Map View',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Google Maps will be integrated',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Route info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.place,
                          color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Location',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Water Depot - Kinondoni',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '123 Depot Road, Kinondoni',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Location',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Customer Address',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '123 Main Street, Oysterbay',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trip info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTripInfo('Distance', '2.5 km', Icons.straighten),
                _buildTripInfo('Est. Time', '15-20 min', Icons.timer),
                _buildTripInfo('Traffic', 'Light', Icons.traffic),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: _isNavigating ? 'Navigating...' : 'Start Navigation',
              onPressed: _isNavigating ? () {} : _startNavigation,
              icon: Icons.navigation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  void _startNavigation() async {
    setState(() {
      _isNavigating = true;
    });

    // Simulate navigation
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isNavigating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation started'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
