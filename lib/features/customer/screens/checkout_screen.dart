import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/providers/auth_provider.dart';
import 'package:water_delivery_app/shared/providers/cart_provider.dart';
import 'package:water_delivery_app/shared/services/address_service.dart'
    as address_service;
import 'package:water_delivery_app/shared/services/order_service.dart';
import 'package:water_delivery_app/shared/services/zone_service.dart';
import 'package:water_delivery_app/shared/models/address_model.dart';
import 'package:water_delivery_app/shared/models/product_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  Address? _selectedAddress;
  List<Address> _addresses = [];
  String _selectedPaymentMethod = 'cash';
  String _notes = '';
  bool _isLoadingAddresses = true;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'value': 'cash',
      'label': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Pay when you receive'
    },
    {
      'value': 'mobile_money',
      'label': 'Mobile Money',
      'icon': Icons.phone_android,
      'description': 'M-Pesa, Tigo Pesa, etc.'
    },
    {
      'value': 'card',
      'label': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final addresses = await address_service.AddressService.getUserAddresses(
            authProvider.currentUser!.id);
        setState(() {
          _addresses = addresses;
          _selectedAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.isNotEmpty
                ? addresses.first
                : throw Exception('No addresses found'),
          );
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      final zone = await ZoneService.getZoneForAddress(
        _selectedAddress!.latitude,
        _selectedAddress!.longitude,
      );

      final deliveryFee = zone != null
          ? await ZoneService.calculateDeliveryFee(
              zone.id, 5.0) // Calculate actual distance
          : 2000.0;

      final order = await OrderService.createOrder(
        customerId: authProvider.currentUser!.id,
        deliveryAddressId: _selectedAddress!.id,
        cartItems: cartProvider.items,
        deliveryFee: deliveryFee,
        notes: _notes.isEmpty ? null : _notes,
      );

      cartProvider.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.orderTracking,
          arguments: {'orderId': order.id},
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;
    final subtotal = cartProvider.totalAmount;
    const deliveryFee = 2000.0;
    const freeDeliveryThreshold = 50000.0;
    final isFreeDelivery = subtotal >= freeDeliveryThreshold;
    final finalDeliveryFee = isFreeDelivery ? 0.0 : deliveryFee;
    final total = subtotal + finalDeliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Delivery Address
                  _buildAddressSection(),
                  const SizedBox(height: 16),

                  // Order Items
                  _buildOrderItems(items),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildPaymentSection(),
                  const SizedBox(height: 16),

                  // Order Notes
                  _buildOrderNotes(),
                  const SizedBox(height: 16),

                  // Order Summary
                  _buildOrderSummary(
                      subtotal, finalDeliveryFee, total, isFreeDelivery),
                  const SizedBox(height: 24),

                  // Place Order Button
                  CustomButton(
                    text: _isProcessing
                        ? 'Processing...'
                        : 'Place Order (TZS ${total.toStringAsFixed(0)})',
                    onPressed: _placeOrder,
                    isLoading: _isProcessing,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.savedAddresses);
                  _loadAddresses();
                },
                child: const Text('Change'),
              ),
            ],
          ),
          if (_isLoadingAddresses)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_addresses.isEmpty)
            Column(
              children: [
                const Text('No saved addresses'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addressForm);
                  },
                  child: const Text('Add Address'),
                ),
              ],
            )
          else if (_selectedAddress != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedAddress!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (_selectedAddress!.isDefault)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.primary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_selectedAddress!.fullAddress,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(_selectedAddress!.phone,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.product.bottleType == 'tank'
                            ? Icons.opacity
                            : Icons.water_drop,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${item.product.sizeLabel} • Qty: ${item.quantity}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'TZS ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._paymentMethods.map((method) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  title: Text(method['label'],
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(method['description'],
                      style: const TextStyle(fontSize: 12)),
                  value: method['value'],
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) =>
                      setState(() => _selectedPaymentMethod = value!),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(method['icon'], color: AppColors.primary),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Notes (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 2,
            onChanged: (value) => _notes = value,
            decoration: InputDecoration(
              hintText: 'Add special instructions for delivery...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
      double subtotal, double deliveryFee, double total, bool isFreeDelivery) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', 'TZS ${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Fee',
            isFreeDelivery ? 'Free' : 'TZS ${deliveryFee.toStringAsFixed(0)}',
            highlight: isFreeDelivery,
          ),
          const Divider(height: 24),
          _buildSummaryRow('Total', 'TZS ${total.toStringAsFixed(0)}',
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Colors.green : null,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add items to proceed to checkout',
              style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Browse Water',
            onPressed: () => Navigator.pop(context),
            width: 200,
          ),
        ],
      ),
    );
  }
}
