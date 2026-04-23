import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';
import 'package:water_delivery_app/core/widgets/custom_textfield.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  String _selectedMethod = 'Bank Transfer';
  String _selectedBank = 'CRDB Bank';
  String _amount = '';
  bool _isProcessing = false;

  final int _availableBalance = 125000;
  final int _minimumWithdrawal = 50000;

  final List<String> _withdrawalMethods = [
    'Bank Transfer',
    'Mobile Money',
    'Cash Pickup'
  ];
  final List<String> _banks = [
    'CRDB Bank',
    'NMB Bank',
    'NBC Bank',
    'Stanbic Bank',
    'Absa Bank'
  ];
  final List<String> _mobileMoneyProviders = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'Halo Pesa'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw Earnings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance card
            _buildBalanceCard(),
            const SizedBox(height: 24),

            // Withdrawal method selector
            _buildMethodSelector(),
            const SizedBox(height: 16),

            // Method specific fields
            if (_selectedMethod == 'Bank Transfer') _buildBankTransferFields(),
            if (_selectedMethod == 'Mobile Money') _buildMobileMoneyFields(),
            if (_selectedMethod == 'Cash Pickup') _buildCashPickupFields(),

            const SizedBox(height: 16),

            // Amount input
            _buildAmountInput(),
            const SizedBox(height: 8),

            // Withdrawal info
            _buildWithdrawalInfo(),
            const SizedBox(height: 24),

            // Withdrawal button
            CustomButton(
              text: _isProcessing ? 'Processing...' : 'Withdraw Funds',
              onPressed: _isProcessing ? () {} : _processWithdrawal,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'TZS ${_formatNumber(_availableBalance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum withdrawal: TZS ${_formatNumber(_minimumWithdrawal)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _withdrawalMethods.map((method) {
              final isSelected = _selectedMethod == method;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.greyLight,
                      ),
                    ),
                    child: Text(
                      method,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedBank,
            decoration: const InputDecoration(
              labelText: 'Select Bank',
              border: OutlineInputBorder(),
            ),
            items: _banks.map((bank) {
              return DropdownMenuItem(value: bank, child: Text(bank));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          const CustomTextField(
            label: 'Account Number',
            hint: 'Enter your bank account number',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const CustomTextField(
            label: 'Account Name',
            hint: 'Enter account holder name',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _mobileMoneyProviders[0],
            decoration: const InputDecoration(
              labelText: 'Select Provider',
              border: OutlineInputBorder(),
            ),
            items: _mobileMoneyProviders.map((provider) {
              return DropdownMenuItem(value: provider, child: Text(provider));
            }).toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 12),
          const CustomTextField(
            label: 'Phone Number',
            hint: 'Enter your mobile money number',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildCashPickupFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          CustomTextField(
            label: 'Pickup Location',
            hint: 'Enter your preferred pickup location',
          ),
          SizedBox(height: 12),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter your phone number for notification',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: 'TZS ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Enter amount',
            ),
            onChanged: (value) {
              setState(() {
                _amount = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalInfo() {
    final int amount = int.tryParse(_amount) ?? 0;
    final bool isValid =
        amount >= _minimumWithdrawal && amount <= _availableBalance;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValid
                  ? 'You will receive TZS ${_formatNumber(amount)} in your account'
                  : 'Amount must be between TZS ${_formatNumber(_minimumWithdrawal)} and TZS ${_formatNumber(_availableBalance)}',
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal() async {
    final int amount = int.tryParse(_amount) ?? 0;

    if (amount < _minimumWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount is below minimum withdrawal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Withdrawal Request Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                'Your withdrawal request of TZS ${_formatNumber(amount)} has been submitted.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Funds will be processed within 1-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
