import 'package:flutter/material.dart';
import 'app_routes.dart';
// Auth Screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/language_screen.dart';
// Customer Screens
import '../../features/customer/home/customer_home_screen.dart';
import '../../features/customer/water_selection/water_selection_screen.dart';
import '../../features/customer/checkout/checkout_screen.dart';
import '../../features/customer/orders/order_tracking_screen.dart';
import '../../features/customer/orders/order_details_screen.dart';
import '../../features/customer/orders/order_history_screen.dart';
import '../../features/customer/profile/profile_screen.dart';
import '../../features/customer/profile/settings_screen.dart';
import '../../features/customer/notifications/notifications_screen.dart';
import '../../features/customer/location/saved_addresses_screen.dart';
import '../../features/customer/location/map_picker_screen.dart';
import '../../features/customer/location/address_form_screen.dart';
// Delivery Screens
import '../../features/delivery/dashboard/delivery_dashboard_screen.dart';
import '../../features/delivery/dashboard/online_status_screen.dart';
import '../../features/delivery/orders/incoming_orders_screen.dart';
import '../../features/delivery/orders/active_delivery_screen.dart';
import '../../features/delivery/orders/delivery_history_screen.dart';
import '../../features/delivery/earnings/earnings_screen.dart';
import '../../features/delivery/earnings/withdrawal_screen.dart';
import '../../features/delivery/earnings/transactions_screen.dart';
import '../../features/delivery/profile/delivery_profile_screen.dart';
import '../../features/delivery/profile/settings_screen.dart';
import '../../features/delivery/profile/verification_screen.dart';
import '../../features/delivery/navigation/map_navigation_screen.dart';
import '../../features/delivery/navigation/delivery_details_screen.dart';
// Admin Screens
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/users/customers_list_screen.dart';
import '../../features/admin/users/delivery_list_screen.dart';
import '../../features/admin/users/user_details_screen.dart';
import '../../features/admin/orders/all_orders_screen.dart';
import '../../features/admin/orders/order_details_screen.dart';
import '../../features/admin/zones/create_zone_screen.dart';
import '../../features/admin/zones/zone_map_screen.dart';
import '../../features/admin/zones/assign_drivers_screen.dart';
import '../../features/admin/payments/transactions_screen.dart';
import '../../features/admin/payments/commission_screen.dart';

// We'll import screens after creating them
// This is the structure for route generation

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());

      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen());

      case AppRoutes.language:
        return _buildRoute(const LanguageScreen());

      case AppRoutes.login:
        return _buildRoute(const LoginScreen());

      case AppRoutes.register:
        return _buildRoute(const RegisterScreen());

      // Customer Routes
      case AppRoutes.customerHome:
        return _buildRoute(const CustomerHomeScreen());

      case AppRoutes.waterSelection:
        return _buildRoute(const WaterSelectionScreen());

      case AppRoutes.checkout:
        return _buildRoute(const CheckoutScreen());

      case AppRoutes.orderTracking:
        return _buildRoute(const OrderTrackingScreen());

      case AppRoutes.orderDetails:
        return _buildRoute(const OrderDetailsScreen());

      case AppRoutes.orderHistory:
        return _buildRoute(const OrderHistoryScreen());

      case AppRoutes.customerProfile:
        return _buildRoute(const ProfileScreen());

      case AppRoutes.customerSettings:
        return _buildRoute(const SettingsScreen());

      case AppRoutes.notifications:
        return _buildRoute(const NotificationsScreen());

      case AppRoutes.savedAddresses:
        return _buildRoute(const SavedAddressesScreen());

      case AppRoutes.mapPicker:
        return _buildRoute(const MapPickerScreen());

      case AppRoutes.addressForm:
        return _buildRoute(const AddressFormScreen());

      // Delivery Routes
      case AppRoutes.deliveryDashboard:
        return _buildRoute(const DeliveryDashboardScreen());

      case AppRoutes.onlineStatus:
        return _buildRoute(const OnlineStatusScreen());

      case AppRoutes.incomingOrders:
        return _buildRoute(const IncomingOrdersScreen());

      case AppRoutes.activeDelivery:
        return _buildRoute(const ActiveDeliveryScreen());

      case AppRoutes.deliveryHistory:
        return _buildRoute(const DeliveryHistoryScreen());

      case AppRoutes.earnings:
        return _buildRoute(const EarningsScreen());

      case AppRoutes.withdrawal:
        return _buildRoute(const WithdrawalScreen());

      case AppRoutes.transactions:
        return _buildRoute(const TransactionsScreen());

      case AppRoutes.deliveryProfile:
        return _buildRoute(const DeliveryProfileScreen());

      case AppRoutes.deliverySettings:
        return _buildRoute(const DeliverySettingsScreen());

      case AppRoutes.verification:
        return _buildRoute(const VerificationScreen());

      case AppRoutes.mapNavigation:
        return _buildRoute(const MapNavigationScreen());

      case AppRoutes.deliveryDetails:
        return _buildRoute(const DeliveryDetailsScreen());

      // Admin Routes
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboardScreen());

      case AppRoutes.customersList:
        return _buildRoute(const CustomersListScreen());

      case AppRoutes.deliveryList:
        return _buildRoute(const DeliveryListScreen());

      case AppRoutes.userDetails:
        return _buildRoute(const UserDetailsScreen());

      case AppRoutes.allOrders:
        return _buildRoute(const AllOrdersScreen());

      case AppRoutes.adminOrderDetails:
        return _buildRoute(const AdminOrderDetailsScreen());

      case AppRoutes.createZone:
        return _buildRoute(const CreateZoneScreen());

      case AppRoutes.zoneMap:
        return _buildRoute(const ZoneMapScreen());

      case AppRoutes.assignDrivers:
        return _buildRoute(const AssignDriversScreen());

      case AppRoutes.transactionsList:
        return _buildRoute(const AdminTransactionsScreen());

      case AppRoutes.commissionSettings:
        return _buildRoute(const CommissionScreen());

      // Default
      default:
        return _errorRoute();
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(
      builder: (context) => screen,
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
