import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/shared/services/order_service.dart';
import 'package:water_delivery_app/shared/models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final orderId = args?['orderId'] as String?;
    if (orderId != null) {
      _loadOrder(orderId);
    }
  }

  Future<void> _loadOrder(String orderId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await OrderService.getOrderById(orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await OrderService.updateOrderStatus(_order!.id, OrderStatus.cancelled);
        await _loadOrder(_order!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Order cancelled'),
                backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: ${e.toString()}')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order ${_order?.orderNumber ?? 'Details'}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _order == null
                  ? _buildNotFoundView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Order Status
                          _buildStatusCard(),
                          const SizedBox(height: 16),

                          // Delivery Address
                          _buildDeliveryAddress(),
                          const SizedBox(height: 16),

                          // Order Items
                          _buildOrderItems(),
                          const SizedBox(height: 16),

                          // Payment Summary
                          _buildPaymentSummary(),
                          const SizedBox(height: 16),

                          // Action Buttons
                          if (_order!.status == OrderStatus.pending ||
                              _order!.status == OrderStatus.confirmed)
                            _buildActionButtons(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _order!.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _order!.status.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Status',
                        style: TextStyle(fontSize: 12, color: AppColors.grey)),
                    Text(
                      _order!.status.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _order!.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (_order!.status == OrderStatus.outForDelivery)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.orderTracking);
                  },
                  child: const Text('Track'),
                ),
            ],
          ),
          if (_order!.status == OrderStatus.outForDelivery)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your order is out for delivery and will arrive soon!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Home',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '123 Main Street, Oysterbay, Dar es Salaam',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._order!.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.bottleType == 'tank'
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
                          Text(item.productName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${item.volumeLiters}L • Qty: ${item.quantity}',
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

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSummaryRow(
              'Subtotal', 'TZS ${_order!.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
              'Delivery Fee', 'TZS ${_order!.deliveryFee.toStringAsFixed(0)}'),
          if (_order!.discountAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildSummaryRow('Discount',
                  '- TZS ${_order!.discountAmount.toStringAsFixed(0)}',
                  highlight: true),
            ),
          const Divider(height: 24),
          _buildSummaryRow(
              'Total', 'TZS ${_order!.totalAmount.toStringAsFixed(0)}',
              isBold: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.payment, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Payment Method:'),
                const Spacer(),
                Text(
                  _order!.paymentStatus == PaymentStatus.completed
                      ? 'Paid'
                      : 'Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _order!.paymentStatus == PaymentStatus.completed
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
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
            onPressed: _cancelOrder,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel Order'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Reorder',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.waterSelection);
            },
          ),
        ),
      ],
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
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Failed to load order', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 24),
          CustomButton(
              text: 'Go Back',
              onPressed: () => Navigator.pop(context),
              width: 150),
        ],
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Order not found', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          CustomButton(
              text: 'Go Back',
              onPressed: () => Navigator.pop(context),
              width: 150),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_order!.status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.local_drink;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.home;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
