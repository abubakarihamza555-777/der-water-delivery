import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class AssignDriversScreen extends StatefulWidget {
  const AssignDriversScreen({super.key});

  @override
  State<AssignDriversScreen> createState() => _AssignDriversScreenState();
}

class _AssignDriversScreenState extends State<AssignDriversScreen> {
  String _selectedZone = 'Zone A - Kinondoni';
  final List<String> _zones = ['Zone A - Kinondoni', 'Zone B - Ilala', 'Zone C - Temeke'];
  
  final List<DriverAssignment> _drivers = [
    DriverAssignment('John Driver', true, 4.8, 45),
    DriverAssignment('Jane Rider', true, 4.9, 38),
    DriverAssignment('Mike Wilson', false, 4.5, 12),
    DriverAssignment('Sarah Bike', false, 4.7, 25),
    DriverAssignment('Peter Moto', true, 4.6, 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assign Drivers to Zone'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Zone selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Zone',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedZone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _zones.map((zone) {
                    return DropdownMenuItem(value: zone, child: Text(zone));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedZone = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard('Total Drivers', '${_drivers.length}', Icons.people),
                _buildStatCard('Assigned', _drivers.where((d) => d.isAssigned).length.toString(), Icons.check_circle),
                _buildStatCard('Available', _drivers.where((d) => !d.isAssigned).length.toString(), Icons.person_add),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Drivers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _drivers.length,
              itemBuilder: (context, index) {
                final driver = _drivers[index];
                return _buildDriverTile(driver, index);
              },
            ),
          ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Save Assignments',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignments saved!')),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
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

  Widget _buildDriverTile(DriverAssignment driver, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: driver.isAssigned 
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: driver.isAssigned
            ? Border.all(color: AppColors.primary)
            : null,
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
                Text(
                  driver.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(driver.rating.toString()),
                    const SizedBox(width: 8),
                    Text('${driver.deliveries} deliveries', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: driver.isAssigned,
            onChanged: (value) {
              setState(() {
                driver.isAssigned = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class DriverAssignment {
  final String name;
  bool isAssigned;
  final double rating;
  final int deliveries;

  DriverAssignment(this.name, this.isAssigned, this.rating, this.deliveries);
} 
