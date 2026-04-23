import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Pending', 'Failed'];
  String _searchQuery = '';
  
  final List<PaymentTransaction> _transactions = [
    PaymentTransaction(
      id: 'TXN-001',
      orderId: 'ORD-12345',
      customer: 'John Doe',
      amount: 12000,
      method: 'Cash',
      status: 'Completed',
      date: 'Dec 22, 2024',
      time: '2:30 PM',
    ),
    PaymentTransaction(
      id: 'TXN-002',
      orderId: 'ORD-12346',
      customer: 'Jane Smith',
      amount: 150000,
      method: 'Mobile Money',
      status: 'Completed',
      date: 'Dec 22, 2024',
      time: '11:15 AM',
    ),
    PaymentTransaction(
      id: 'TXN-003',
      orderId: 'ORD-12347',
      customer: 'Robert Johnson',
      amount: 5000,
      method: 'Cash',
      status: 'Pending',
      date: 'Dec 21, 2024',
      time: '4:45 PM',
    ),
  ];

  List<PaymentTransaction> get _filteredTransactions {
    var transactions = _transactions;
    
    if (_selectedFilter != 'All') {
      transactions = transactions.where((t) => t.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((t) =>
        t.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.customer.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return transactions;
  }

  int get _totalRevenue {
    return _transactions
        .where((t) => t.status == 'Completed')
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Transactions'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Revenue card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Revenue', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Text('All Time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Text(
                  'TZS ${_totalRevenue.toString()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => _buildFilterChip(_filters[index]),
                ),
              ),
            ),
          ),
          
          // Transactions list
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 80, color: AppColors.grey),
          SizedBox(height: 16),
          Text('No transactions found'),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.id,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.shopping_bag, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(transaction.orderId, style: const TextStyle(fontSize: 12)),
              const Spacer(),
              const Icon(Icons.person, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(transaction.customer, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payment, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(transaction.method, style: const TextStyle(fontSize: 12)),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(transaction.date, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount'),
              Text(
                'TZS ${transaction.amount}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final String customer;
  final int amount;
  final String method;
  final String status;
  final String date;
  final String time;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.customer,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
    required this.time,
  });
} 
