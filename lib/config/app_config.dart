class AppConfig {
  // App Information
  static const String appName = 'Dar Water Delivery';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.waterdelivery.app';

  // Environment
  static const Environment environment = Environment.production;

  // API Configuration - Now using Supabase
  static String get supabaseUrl {
    return 'https://fqvdqspdqyfeblxgjozz.supabase.co';
  }

  static String get supabaseAnonKey {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdmRxc3BkcXlmZWJseGdqb3p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNDYyNjEsImV4cCI6MjA5MjYyMjI2MX0.EbUpbwbzsArIjmPHU7RVNVK6N9Fq9sUfmXCXbGuc4x0';
  }

  static String get apiVersion {
    return 'v1';
  }

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  static const bool enableGoogleMaps = true;
  static const bool enablePaymentGateway = true;

  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Cache
  static const int cacheDuration = 3600; // 1 hour in seconds

  // Payment
  static const String currencyCode = 'TZS';
  static const String currencySymbol = 'TSh';

  // Location
  static const double defaultLatitude = -6.7924;
  static const double defaultLongitude = 39.2083;
  static const int defaultZoomLevel = 14;

  // Delivery
  static const double baseDeliveryFee = 2000;
  static const double deliveryFeePerKm = 500;
  static const double freeDeliveryThreshold = 50000;

  // Commission
  static const double deliveryCommission = 20.0; // 20%
  static const double platformCommission = 10.0; // 10%

  // Order Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];
}

enum Environment {
  development,
  staging,
  production,
}
