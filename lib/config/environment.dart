import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class EnvironmentConfig {
  // Current environment
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode && !kProfileMode;
  static bool get isProfile => kProfileMode;

  // Environment flags
  static bool get useMockData => false; // Always use live database for production
  static bool get logNetworkCalls => isDevelopment;
  static bool get logAnalytics => isProduction;

  // API Keys (use .env file in production)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String paymentGatewayKey = 'YOUR_PAYMENT_GATEWAY_KEY';

  // Firebase Configurations
  static const String firebaseProjectId = 'water-delivery-app';
  static const String firebaseAppId = '1:123456789:android:abcdef';

  // Deep Links
  static const String deepLinkScheme = 'waterdelivery';
  static const String deepLinkHost = 'app.waterdelivery.com';

  // Social Media
  static const String privacyPolicyUrl = 'https://waterdelivery.com/privacy';
  static const String termsOfServiceUrl = 'https://waterdelivery.com/terms';
  static const String aboutUrl = 'https://waterdelivery.com/about';
  static const String supportEmail = 'support@waterdelivery.com';

  // App Store Links
  static const String androidAppId = 'com.waterdelivery.app';
  static const String iosAppId = '123456789';

  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$androidAppId';
  static String get appStoreUrl => 'https://apps.apple.com/app/id$iosAppId';

  // Minimum app version
  static const int minimumAndroidVersion = 21; // Android 5.0
  static const int minimumiOSVersion = 12; // iOS 12.0

  // Rate app
  static const int rateAppAfterDays = 7;
  static const int rateAppAfterOrders = 5;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
  static const String productsCollection = 'products';
  static const String addressesCollection = 'addresses';
  static const String paymentsCollection = 'payments';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys
  static const String prefUser = 'user';
  static const String prefToken = 'token';
  static const String prefLanguage = 'language';
  static const String prefTheme = 'theme';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefOnboardingCompleted = 'onboarding_completed';

  // Logging
  static const bool enableVerboseLogging = true;
  static const bool enableApiLogging = true;
  static const bool enableDatabaseLogging = false;
}

// Environment helper extension
extension EnvironmentExtension on EnvironmentConfig {
  static String getEnvironmentName() {
    if (EnvironmentConfig.isDevelopment) return 'Development';
    if (EnvironmentConfig.isProduction) return 'Production';
    return 'Profile';
  }

  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'name': getEnvironmentName(),
      'version': '1.0.0',
      'buildNumber': '1',
      'apiUrl': AppConfig.supabaseUrl,
      'useMockData': EnvironmentConfig.useMockData,
    };
  }
}
