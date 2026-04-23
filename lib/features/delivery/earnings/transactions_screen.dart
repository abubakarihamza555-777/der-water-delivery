import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Earnings', 'Withdrawals', 'Bonuses'];
  
  final List<Transaction> _transactions = [
    Transaction(
      id: 'TXN-001',
      type: 'Earnings',
      amount: 35000,
      description: 'Delivery #ORD-12345',
      date: 'Dec 22, 2024',
      time: '2:30 PM',
      status: 'Completed',
      isCredit: true,
    ),
    Transaction(
      id: 'TXN-002',
      type: 'Earnings',
      amount: 42000,
      description: 'Delivery #ORD-12346',
      date: 'Dec 21, 2024',
      time: '11:15 AM',
      status: 'Completed',
      isCredit: true,
    ),
    Transaction(
      id: 'TXN-003',
      type: 'Withdrawal',
      amount: 100000,
      description: 'Bank Transfer to CRDB',
      date: 'Dec 20, 2024',
      time: '9:00 AM',
      status: 'Processing',
      isCredit: false,
    ),
    Transaction(
      id: 'TXN-004',
      type: 'Bonus',
      amount: 5000,
      description: 'Weekly Bonus - Top Performer',
      date: 'Dec 19, 2024',
      time: '5:00 PM',
      status: 'Completed',
      isCredit: true,
    ),
    Transaction(
      id: 'TXN-005',
      type: 'Earnings',
      amount: 28000,
      description: 'Delivery #ORD-12347',
      date: 'Dec 18, 2024',
      time: '4:45 PM',
      status: 'Completed',
      isCredit: true,
    ),
    Transaction(
      id: 'TXN-006',
      type: 'Withdrawal',
      amount: 50000,
      description: 'M-Pesa Transfer',
      date: 'Dec 15, 2024',
      time: '10:30 AM',
      status: 'Completed',
      isCredit: false,
    ),
  ];

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    }
    return _transactions.where((t) => t.type == _selectedFilter).toList();
  }

  int get _totalEarnings {
    return _transactions
        .where((t) => t.isCredit && t.status == 'Completed')
        .fold(0, (sum, t) => sum + t.amount);
  }

  int get _totalWithdrawn {
    return _transactions
        .where((t) => !t.isCredit && t.status == 'Completed')
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard(
                  'Total Earnings',
                  'TZS ${_formatNumber(_totalEarnings)}',
                  Icons.trending_up,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  'Total Withdrawn',
                  'TZS ${_formatNumber(_totalWithdrawn)}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ],
            ),
          ),
          
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.greyLight,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isCredit 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.isCredit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date} • ${transaction.time}',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'} TZS ${_formatNumber(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.type,
                style: const TextStyle(fontSize: 11, color: AppColors.grey),
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
      case 'Processing':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return AppColors.grey;
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

class Transaction {
  final String id;
  final String type;
  final int amount;
  final String description;
  final String date;
  final String time;
  final String status;
  final bool isCredit;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.isCredit,
  });
} 
