import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];
  
  final EarningsData _earnings = EarningsData(
    totalEarnings: 450000,
    thisWeek: 125000,
    thisMonth: 450000,
    pendingWithdrawal: 50000,
    completedDeliveries: 45,
    rating: 4.8,
  );

  final List<DailyEarning> _dailyEarnings = [
    DailyEarning('Monday', 'Dec 16', 35000, 3),
    DailyEarning('Tuesday', 'Dec 17', 42000, 4),
    DailyEarning('Wednesday', 'Dec 18', 28000, 2),
    DailyEarning('Thursday', 'Dec 19', 38000, 3),
    DailyEarning('Friday', 'Dec 20', 45000, 4),
    DailyEarning('Saturday', 'Dec 21', 52000, 5),
    DailyEarning('Sunday', 'Dec 22', 25000, 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _showPeriodSelector();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total earnings card
            _buildTotalEarningsCard(),
            const SizedBox(height: 16),
            
            // Stats cards
            _buildStatsRow(),
            const SizedBox(height: 16),
            
            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            
            // Earnings chart
            _buildEarningsChart(),
            const SizedBox(height: 16),
            
            // Daily earnings list
            _buildDailyEarningsList(),
            const SizedBox(height: 16),
            
            // Withdrawal button
            _buildWithdrawalButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TZS ${_formatNumber(_earnings.totalEarnings)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalInfo('This Week', 'TZS ${_formatNumber(_earnings.thisWeek)}'),
              _buildTotalInfo('This Month', 'TZS ${_formatNumber(_earnings.thisMonth)}'),
              _buildTotalInfo('Pending', 'TZS ${_formatNumber(_earnings.pendingWithdrawal)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${_earnings.completedDeliveries}',
            'Deliveries',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rating',
            '${_earnings.rating}',
            '⭐ Average',
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.greyLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsChart() {
    // Find max value for scaling
    final maxEarning = _dailyEarnings.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    
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
            'Earnings Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_dailyEarnings.length, (index) {
                final earning = _dailyEarnings[index];
                final height = (earning.amount / maxEarning) * 150;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'TZS ${(earning.amount / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        earning.day.substring(0, 3),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEarningsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Daily Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dailyEarnings.length,
            itemBuilder: (context, index) {
              final earning = _dailyEarnings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            earning.day,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            earning.date,
                            style: const TextStyle(fontSize: 11, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${earning.deliveries} deliveries',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      'TZS ${_formatNumber(earning.amount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.withdrawal);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Withdraw Earnings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _periods.map((period) {
              return ListTile(
                title: Text(period),
                trailing: _selectedPeriod == period
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
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

class EarningsData {
  final int totalEarnings;
  final int thisWeek;
  final int thisMonth;
  final int pendingWithdrawal;
  final int completedDeliveries;
  final double rating;

  EarningsData({
    required this.totalEarnings,
    required this.thisWeek,
    required this.thisMonth,
    required this.pendingWithdrawal,
    required this.completedDeliveries,
    required this.rating,
  });
}

class DailyEarning {
  final String day;
  final String date;
  final int amount;
  final int deliveries;

  DailyEarning(this.day, this.date, this.amount, this.deliveries);
} 
