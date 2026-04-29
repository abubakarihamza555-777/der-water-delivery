import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/providers/auth_provider.dart';
import 'package:water_delivery_app/shared/providers/cart_provider.dart';
import 'package:water_delivery_app/shared/services/product_service.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

class BulkWaterOrderScreen extends StatefulWidget {
  const BulkWaterOrderScreen({super.key});

  @override
  State<BulkWaterOrderScreen> createState() => _BulkWaterOrderScreenState();
}

class _BulkWaterOrderScreenState extends State<BulkWaterOrderScreen> {
  final TextEditingController _litersController = TextEditingController();
  int _selectedLiters = 1000;
  bool _deliverNow = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  Product? _selectedProduct;
  double _pricePerLiter = 25.0;
  double _deliveryFee = 5000.0;
  String _deliveryLocation = 'Mbezi Beach, Dar es Salaam';

  final List<int> _quickSelectLiters = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _loadBulkProducts();
    _litersController.text = _selectedLiters.toString();
  }

  Future<void> _loadBulkProducts() async {
    try {
      final products = await ProductService.getProducts();
      final bulkProducts = products.where((p) => p.deliveryType == 'bulk').toList();
      if (bulkProducts.isNotEmpty) {
        setState(() {
          _selectedProduct = bulkProducts.first;
          _pricePerLiter = bulkProducts.first.pricePerLiter;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    super.dispose();
  }

  double get _totalPrice => (_selectedLiters * _pricePerLiter) + _deliveryFee;

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
          'Bulk Water (Truck)',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Truck Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/truck.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Enter Liters Section
            const Text(
              'Enter Liters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _litersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount in liters',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                final liters = int.tryParse(value) ?? 0;
                setState(() {
                  _selectedLiters = liters;
                });
              },
            ),
            const SizedBox(height: 16),

            // Quick Select Buttons
            Row(
              children: _quickSelectLiters.map((liters) {
                final isSelected = _selectedLiters == liters;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLiters = liters;
                        _litersController.text = liters.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey,
                        ),
                      ),
                      child: Text(
                        '${liters} L',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Price Details
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
              child: Column(
                children: [
                  _buildPriceRow('Price per liter', 'TZS ${_pricePerLiter.toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Delivery fee', 'TZS ${_deliveryFee.toStringAsFixed(0)}'),
                  const Divider(height: 24),
                  _buildPriceRow(
                    'Total',
                    'TZS ${_totalPrice.toStringAsFixed(0)}',
                    isBold: true,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Options
            const Text(
              'Delivery Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
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
              child: Column(
                children: [
                  _buildDeliveryOption('Deliver Now', true),
                  const SizedBox(height: 12),
                  _buildDeliveryOption('Schedule for Later', false),
                ],
              ),
            ),
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
            const SizedBox(height: 12),
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

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(String title, bool isDeliverNow) {
    final isSelected = (isDeliverNow && _deliverNow) || (!isDeliverNow && !_deliverNow);
    return GestureDetector(
      onTap: () {
        setState(() {
          _deliverNow = isDeliverNow;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _continueToCheckout() {
    if (_selectedLiters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Add to cart and navigate to checkout
    if (_selectedProduct != null) {
      final cartProvider = context.read<CartProvider>();
      
      // Create a custom product for the bulk order
      final bulkProduct = Product(
        id: _selectedProduct!.id,
        name: 'Bulk Water (${_selectedLiters}L)',
        volumeLiters: _selectedLiters,
        bottleType: 'tank',
        price: _selectedLiters * _pricePerLiter,
        pricePerLiter: _pricePerLiter,
        deliveryType: 'bulk',
        baseDeliveryFee: _deliveryFee,
        isActive: true,
        description: 'Bulk water delivery by truck',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      cartProvider.addItem(bulkProduct, 1);
      
      Navigator.pushNamed(context, AppRoutes.checkout, arguments: {
        'scheduledFor': _deliverNow ? null : _scheduledDate,
        'deliveryType': 'bulk',
      });
    }
  }
}
