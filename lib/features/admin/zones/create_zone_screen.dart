import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/core/widgets/custom_textfield.dart';

class CreateZoneScreen extends StatefulWidget {
  const CreateZoneScreen({super.key});

  @override
  State<CreateZoneScreen> createState() => _CreateZoneScreenState();
}

class _CreateZoneScreenState extends State<CreateZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _zoneNameController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _minOrderController = TextEditingController();

  final List<String> _selectedAreas = [];
  final List<String> _availableAreas = [
    'Oysterbay',
    'Masaki',
    'Kinondoni',
    'Msasani',
    'Upanga',
    'Kariakoo',
    'Posta',
    'Kivukoni',
    'Mikocheni',
    'Mbezi Beach',
    'Kawe',
    'Kunduchi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Delivery Zone'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Zone name
              CustomTextField(
                label: 'Zone Name',
                controller: _zoneNameController,
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Zone name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pricing
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
                      'Pricing Settings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Base Delivery Fee',
                      controller: _basePriceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.money,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Base fee is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Price per KM',
                      controller: _pricePerKmController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.straighten,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price per KM is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Minimum Order Amount',
                      controller: _minOrderController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.shopping_bag,
                      hint: 'Optional',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Areas selection
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
                      'Covered Areas',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAreas.map((area) {
                        final isSelected = _selectedAreas.contains(area);
                        return FilterChip(
                          label: Text(area),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAreas.add(area);
                              } else {
                                _selectedAreas.remove(area);
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_selectedAreas.length} areas selected',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Zone map preview
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.map, size: 50, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text('Zone Map Preview'),
                    const SizedBox(height: 4),
                    const Text(
                      'Draw zone boundaries on map',
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.zoneMap);
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Draw on Map'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                text: 'Create Zone',
                onPressed: _createZone,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _createZone() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAreas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one area')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _zoneNameController.dispose();
    _basePriceController.dispose();
    _pricePerKmController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }
}
