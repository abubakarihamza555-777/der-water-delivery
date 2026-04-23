import 'package:flutter/material.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Pure Quality Water',
      description: 'Get fresh, purified water delivered to your doorstep',
      icon: Icons.water_drop,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'Fast Delivery',
      description: 'Quick delivery within 30 minutes of ordering',
      icon: Icons.delivery_dining,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'Easy Tracking',
      description: 'Track your order in real-time from our app',
      icon: Icons.location_on,
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Skip button
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.greyDark,
                  ),
                ),
              ),
            ),
          ),
          
          // PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_onboardingData[index]);
              },
            ),
          ),
          
          // Indicators and buttons
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => _buildIndicator(index),
                  ),
                ),
                const SizedBox(height: 32),
                // Next/Get Started button
                CustomButton(
                  text: _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 100,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _completeOnboarding() {
    // TODO: Save onboarding completed status
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 
