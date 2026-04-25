class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String language = '/language';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Customer Routes
  static const String customerHome = '/customer/home';
  static const String waterSelection = '/customer/water-selection';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String orderTracking = '/customer/order-tracking';
  static const String orderDetails = '/customer/order-details';
  static const String orderHistory = '/customer/order-history';
  static const String mapPicker = '/customer/map-picker';
  static const String addressForm = '/customer/address-form';
  static const String savedAddresses = '/customer/saved-addresses';
  static const String customerProfile = '/customer/profile';
  static const String customerSettings = '/customer/settings';
  static const String notifications = '/customer/notifications';

  // Delivery Routes
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String onlineStatus = '/delivery/online-status';
  static const String incomingOrders = '/delivery/incoming-orders';
  static const String activeDelivery = '/delivery/active-delivery';
  static const String deliveryHistory = '/delivery/history';
  static const String mapNavigation = '/delivery/map-navigation';
  static const String deliveryDetails = '/delivery/details';
  static const String earnings = '/delivery/earnings';
  static const String withdrawal = '/delivery/withdrawal';
  static const String transactions = '/delivery/transactions';
  static const String deliveryProfile = '/delivery/profile';
  static const String verification = '/delivery/verification';
  static const String deliverySettings = '/delivery/settings';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String customersList = '/admin/customers';
  static const String deliveryList = '/admin/delivery-persons';
  static const String userDetails = '/admin/user-details';
  static const String allOrders = '/admin/orders';
  static const String adminOrderDetails = '/admin/order-details';
  static const String createZone = '/admin/create-zone';
  static const String assignDrivers = '/admin/assign-drivers';
  static const String zoneMap = '/admin/zone-map';
  static const String transactionsList = '/admin/transactions';
  static const String commissionSettings = '/admin/commission';

  // Route arguments keys
  static const String argOrderId = 'orderId';
  static const String argUserId = 'userId';
  static const String argAddressId = 'addressId';
  static const String argProductId = 'productId';
  static const String argZoneId = 'zoneId';
  static const String argDeliveryId = 'deliveryId';
}

// Route names list for navigation
class RouteNames {
  static const List<String> allRoutes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.language,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.customerHome,
    AppRoutes.waterSelection,
    AppRoutes.cart,
    AppRoutes.checkout,
    AppRoutes.orderTracking,
    AppRoutes.orderDetails,
    AppRoutes.orderHistory,
    AppRoutes.mapPicker,
    AppRoutes.addressForm,
    AppRoutes.savedAddresses,
    AppRoutes.customerProfile,
    AppRoutes.customerSettings,
    AppRoutes.notifications,
    AppRoutes.deliveryDashboard,
    AppRoutes.onlineStatus,
    AppRoutes.incomingOrders,
    AppRoutes.activeDelivery,
    AppRoutes.deliveryHistory,
    AppRoutes.mapNavigation,
    AppRoutes.deliveryDetails,
    AppRoutes.earnings,
    AppRoutes.withdrawal,
    AppRoutes.transactions,
    AppRoutes.deliveryProfile,
    AppRoutes.verification,
    AppRoutes.deliverySettings,
    AppRoutes.adminDashboard,
    AppRoutes.customersList,
    AppRoutes.deliveryList,
    AppRoutes.userDetails,
    AppRoutes.allOrders,
    AppRoutes.adminOrderDetails,
    AppRoutes.createZone,
    AppRoutes.assignDrivers,
    AppRoutes.zoneMap,
    AppRoutes.transactionsList,
    AppRoutes.commissionSettings,
  ];

  // Routes that require authentication
  static const List<String> authRequiredRoutes = [
    AppRoutes.customerHome,
    AppRoutes.waterSelection,
    AppRoutes.cart,
    AppRoutes.checkout,
    AppRoutes.orderTracking,
    AppRoutes.orderDetails,
    AppRoutes.orderHistory,
    AppRoutes.savedAddresses,
    AppRoutes.customerProfile,
    AppRoutes.customerSettings,
    AppRoutes.deliveryDashboard,
    AppRoutes.incomingOrders,
    AppRoutes.activeDelivery,
    AppRoutes.earnings,
    AppRoutes.deliveryProfile,
  ];

  // Routes that require delivery role
  static const List<String> deliveryOnlyRoutes = [
    AppRoutes.deliveryDashboard,
    AppRoutes.onlineStatus,
    AppRoutes.incomingOrders,
    AppRoutes.activeDelivery,
    AppRoutes.deliveryHistory,
    AppRoutes.mapNavigation,
    AppRoutes.deliveryDetails,
    AppRoutes.earnings,
    AppRoutes.withdrawal,
    AppRoutes.transactions,
    AppRoutes.deliveryProfile,
    AppRoutes.verification,
    AppRoutes.deliverySettings,
  ];

  // Routes that require admin role
  static const List<String> adminOnlyRoutes = [
    AppRoutes.adminDashboard,
    AppRoutes.customersList,
    AppRoutes.deliveryList,
    AppRoutes.userDetails,
    AppRoutes.allOrders,
    AppRoutes.adminOrderDetails,
    AppRoutes.createZone,
    AppRoutes.assignDrivers,
    AppRoutes.zoneMap,
    AppRoutes.transactionsList,
    AppRoutes.commissionSettings,
  ];
}
