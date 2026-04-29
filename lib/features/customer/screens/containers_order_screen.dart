import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/providers/auth_provider.dart';
import 'package:water_delivery_app/shared/providers/cart_provider.dart';
import 'package:water_delivery_app/shared/services/product_service.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

class ContainersOrderScreen extends StatefulWidget {
  const ContainersOrderScreen({super.key});

  @override
  State<ContainersOrderScreen> createState() => _ContainersOrderScreenState();
}

class _ContainersOrderScreenState extends State<ContainersOrderScreen> {
  Map<String, int> _quantities = {
    '10L': 0,
    '20L': 0,
  };
  String _deliveryLocation = 'Mbezi Beach, Dar es Salaam';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  double get _totalPrice {
    // Mock prices: 10L = 3000 TZS, 20L = 5000 TZS
    return (_quantities['10L']! * 3000) + (_quantities['20L']! * 5000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Containers (Dumu & Ndoo)',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Containers Image
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/containers.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Select Container Quantity
                const Text(
                  'Select Container Quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 10L Container
                _buildContainerItem('10L Container', 3000, '10L'),
                const SizedBox(height: 12),
                
                // 20L Container  
                _buildContainerItem('20L Container', 5000, '20L'),
                const SizedBox(height: 24),

                // Delivery Location
                const Text(
                  'Delivery Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deliveryLocation,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Change location
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'TZS ${_totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Continue Button
                CustomButton(
                  text: 'Continue',
                  onPressed: _continueToCheckout,
                  width: double.infinity,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );
  }

  Widget _buildContainerItem(String title, int price, String key) {
    final quantity = _quantities[key] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Container Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Container Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TZS ${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (quantity > 0) {
                      setState(() {
                        _quantities[key] = quantity - 1;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _quantities[key] = quantity + 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _continueToCheckout() {
    final hasItems = _quantities.values.any((qty) => qty > 0);
    
    if (!hasItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one container')),
      );
      return;
    }

    // Navigate to checkout with container quantities
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: {
      'deliveryType': 'container',
      'quantities': _quantities,
    });
  }
}
