import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Commission settings
  double _deliveryCommission = 20.0;
  double _platformCommission = 10.0;
  double _bonusPerDelivery = 500.0;
  int _weeklyBonusThreshold = 50;
  
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commission Settings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveSettings();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Delivery Partner Commission
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
                      'Delivery Partner Commission',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Percentage of order value that goes to delivery partners',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildCommissionSlider(
                      'Commission Rate',
                      _deliveryCommission,
                      (value) {
                        setState(() {
                          _deliveryCommission = value;
                        });
                      },
                      '${_deliveryCommission.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Platform Commission
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
                      'Platform Commission',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Platform fee charged on each order',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildCommissionSlider(
                      'Platform Fee',
                      _platformCommission,
                      (value) {
                        setState(() {
                          _platformCommission = value;
                        });
                      },
                      '${_platformCommission.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Bonus Settings
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
                      'Bonus & Incentives',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildBonusField(
                      'Bonus per Delivery',
                      _bonusPerDelivery,
                      (value) {
                        setState(() {
                          _bonusPerDelivery = value;
                        });
                      },
                      'TZS',
                    ),
                    const SizedBox(height: 12),
                    _buildBonusField(
                      'Weekly Bonus Threshold',
                      _weeklyBonusThreshold.toDouble(),
                      (value) {
                        setState(() {
                          _weeklyBonusThreshold = value.toInt();
                        });
                      },
                      'deliveries',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Example Calculation
              _buildExampleCalculation(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionSlider(String label, double value, Function(double) onChanged, String displayValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              displayValue,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: _isEditing ? onChanged : null,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildBonusField(String label, double value, Function(double) onChanged, String unit) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 1,
          child: TextFormField(
            initialValue: value.toStringAsFixed(0),
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: unit,
              isDense: true,
            ),
            onChanged: (val) {
              final newValue = double.tryParse(val) ?? 0;
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCalculation() {
    const orderValue = 10000;
    final deliveryEarning = orderValue * (_deliveryCommission / 100);
    final platformEarning = orderValue * (_platformCommission / 100);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Example Calculation (TZS 10,000 Order)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildExampleRow('Order Value', 'TZS ${orderValue.toString()}'),
          _buildExampleRow('Delivery Partner', 'TZS ${deliveryEarning.toStringAsFixed(0)} (${_deliveryCommission.toStringAsFixed(0)}%)'),
          _buildExampleRow('Platform Fee', 'TZS ${platformEarning.toStringAsFixed(0)} (${_platformCommission.toStringAsFixed(0)}%)'),
          _buildExampleRow('Delivery Bonus', '+ TZS ${_bonusPerDelivery.toStringAsFixed(0)}'),
          const Divider(),
          _buildExampleRow(
            'Total Delivery Earnings',
            'TZS ${(deliveryEarning + _bonusPerDelivery).toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commission settings saved!')),
      );
    }
  }
} 
