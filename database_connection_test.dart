// =====================================================
// DATABASE CONNECTION VERIFICATION SCRIPT
// Water Delivery App - Test All Database Connections
// URL: https://fqvdqspdqyfeblxgjozz.supabase.co
// =====================================================
// 
// This script tests all database connections and verifies data retrieval
// Run this in your Flutter app or as a standalone script
// =====================================================

import 'package:water_delivery_app/core/services/supabase_service.dart';
import 'package:water_delivery_app/shared/services/water_service.dart';

class DatabaseConnectionTest {
  static Map<String, dynamic> results = {};

  static Future<void> runAllTests() async {
    print('🔍 Starting Database Connection Tests...\n');

    // Test 1: Basic Connection
    await testBasicConnection();

    // Test 2: Users Table
    await testUsersTable();

    // Test 3: Water Types Table
    await testWaterTypesTable();

    // Test 4: Orders Table
    await testOrdersTable();

    // Test 5: Addresses Table
    await testAddressesTable();

    // Test 6: Zones Table
    await testZonesTable();

    // Test 7: Deliveries Table
    await testDeliveriesTable();

    // Test 8: Payments Table
    await testPaymentsTable();

    // Test 9: Transactions Table
    await testTransactionsTable();

    // Test 10: Notifications Table
    await testNotificationsTable();

    // Test 11: Reviews Table
    await testReviewsTable();

    // Test 12: Withdrawal Requests Table
    await testWithdrawalRequestsTable();

    // Test 13: Support Tickets Table
    await testSupportTicketsTable();

    // Test 14: Promotions Table
    await testPromotionsTable();

    // Test 15: Zone Assignments Table
    await testZoneAssignmentsTable();

    // Print Summary
    printTestSummary();
  }

  static Future<void> testBasicConnection() async {
    try {
      final response = await SupabaseService.fetch('users', limit: 1);
      results['basic_connection'] = {
        'status': '✅ PASS',
        'message': 'Successfully connected to database',
        'data_count': response.length,
      };
      print('✅ Basic Connection: PASS');
    } catch (e) {
      results['basic_connection'] = {
        'status': '❌ FAIL',
        'message': 'Failed to connect: $e',
      };
      print('❌ Basic Connection: FAIL - $e');
    }
  }

  static Future<void> testUsersTable() async {
    try {
      final data = await SupabaseService.fetch('users', limit: 5);
      results['users_table'] = {
        'status': '✅ PASS',
        'message': 'Users table accessible',
        'total_users': data.length,
        'sample_user': data.isNotEmpty ? data[0]['email'] : 'No users',
      };
      print('✅ Users Table: PASS (${data.length} users found)');
    } catch (e) {
      results['users_table'] = {
        'status': '❌ FAIL',
        'message': 'Users table error: $e',
      };
      print('❌ Users Table: FAIL - $e');
    }
  }

  static Future<void> testWaterTypesTable() async {
    try {
      final waterTypes = await WaterService.getWaterTypes();
      results['water_types_table'] = {
        'status': '✅ PASS',
        'message': 'Water types table accessible',
        'total_types': waterTypes.length,
        'sample_type': waterTypes.isNotEmpty ? waterTypes.first.name : 'No water types',
      };
      print('✅ Water Types Table: PASS (${waterTypes.length} types found)');
    } catch (e) {
      results['water_types_table'] = {
        'status': '❌ FAIL',
        'message': 'Water types table error: $e',
      };
      print('❌ Water Types Table: FAIL - $e');
    }
  }

  static Future<void> testOrdersTable() async {
    try {
      final data = await SupabaseService.fetch('orders', limit: 5);
      results['orders_table'] = {
        'status': '✅ PASS',
        'message': 'Orders table accessible',
        'total_orders': data.length,
        'sample_order': data.isNotEmpty ? data[0]['order_number'] : 'No orders',
      };
      print('✅ Orders Table: PASS (${data.length} orders found)');
    } catch (e) {
      results['orders_table'] = {
        'status': '❌ FAIL',
        'message': 'Orders table error: $e',
      };
      print('❌ Orders Table: FAIL - $e');
    }
  }

  static Future<void> testAddressesTable() async {
    try {
      final data = await SupabaseService.fetch('addresses', limit: 5);
      results['addresses_table'] = {
        'status': '✅ PASS',
        'message': 'Addresses table accessible',
        'total_addresses': data.length,
      };
      print('✅ Addresses Table: PASS (${data.length} addresses found)');
    } catch (e) {
      results['addresses_table'] = {
        'status': '❌ FAIL',
        'message': 'Addresses table error: $e',
      };
      print('❌ Addresses Table: FAIL - $e');
    }
  }

  static Future<void> testZonesTable() async {
    try {
      final data = await SupabaseService.fetch('zones', limit: 5);
      results['zones_table'] = {
        'status': '✅ PASS',
        'message': 'Zones table accessible',
        'total_zones': data.length,
        'sample_zone': data.isNotEmpty ? data[0]['name'] : 'No zones',
      };
      print('✅ Zones Table: PASS (${data.length} zones found)');
    } catch (e) {
      results['zones_table'] = {
        'status': '❌ FAIL',
        'message': 'Zones table error: $e',
      };
      print('❌ Zones Table: FAIL - $e');
    }
  }

  static Future<void> testDeliveriesTable() async {
    try {
      final data = await SupabaseService.fetch('deliveries', limit: 5);
      results['deliveries_table'] = {
        'status': '✅ PASS',
        'message': 'Deliveries table accessible',
        'total_deliveries': data.length,
      };
      print('✅ Deliveries Table: PASS (${data.length} deliveries found)');
    } catch (e) {
      results['deliveries_table'] = {
        'status': '❌ FAIL',
        'message': 'Deliveries table error: $e',
      };
      print('❌ Deliveries Table: FAIL - $e');
    }
  }

  static Future<void> testPaymentsTable() async {
    try {
      final data = await SupabaseService.fetch('payments', limit: 5);
      results['payments_table'] = {
        'status': '✅ PASS',
        'message': 'Payments table accessible',
        'total_payments': data.length,
      };
      print('✅ Payments Table: PASS (${data.length} payments found)');
    } catch (e) {
      results['payments_table'] = {
        'status': '❌ FAIL',
        'message': 'Payments table error: $e',
      };
      print('❌ Payments Table: FAIL - $e');
    }
  }

  static Future<void> testTransactionsTable() async {
    try {
      final data = await SupabaseService.fetch('transactions', limit: 5);
      results['transactions_table'] = {
        'status': '✅ PASS',
        'message': 'Transactions table accessible',
        'total_transactions': data.length,
      };
      print('✅ Transactions Table: PASS (${data.length} transactions found)');
    } catch (e) {
      results['transactions_table'] = {
        'status': '❌ FAIL',
        'message': 'Transactions table error: $e',
      };
      print('❌ Transactions Table: FAIL - $e');
    }
  }

  static Future<void> testNotificationsTable() async {
    try {
      final data = await SupabaseService.fetch('notifications', limit: 5);
      results['notifications_table'] = {
        'status': '✅ PASS',
        'message': 'Notifications table accessible',
        'total_notifications': data.length,
      };
      print('✅ Notifications Table: PASS (${data.length} notifications found)');
    } catch (e) {
      results['notifications_table'] = {
        'status': '❌ FAIL',
        'message': 'Notifications table error: $e',
      };
      print('❌ Notifications Table: FAIL - $e');
    }
  }

  static Future<void> testReviewsTable() async {
    try {
      final data = await SupabaseService.fetch('reviews', limit: 5);
      results['reviews_table'] = {
        'status': '✅ PASS',
        'message': 'Reviews table accessible',
        'total_reviews': data.length,
      };
      print('✅ Reviews Table: PASS (${data.length} reviews found)');
    } catch (e) {
      results['reviews_table'] = {
        'status': '❌ FAIL',
        'message': 'Reviews table error: $e',
      };
      print('❌ Reviews Table: FAIL - $e');
    }
  }

  static Future<void> testWithdrawalRequestsTable() async {
    try {
      final data = await SupabaseService.fetch('withdrawal_requests', limit: 5);
      results['withdrawal_requests_table'] = {
        'status': '✅ PASS',
        'message': 'Withdrawal requests table accessible',
        'total_requests': data.length,
      };
      print('✅ Withdrawal Requests Table: PASS (${data.length} requests found)');
    } catch (e) {
      results['withdrawal_requests_table'] = {
        'status': '❌ FAIL',
        'message': 'Withdrawal requests table error: $e',
      };
      print('❌ Withdrawal Requests Table: FAIL - $e');
    }
  }

  static Future<void> testSupportTicketsTable() async {
    try {
      final data = await SupabaseService.fetch('support_tickets', limit: 5);
      results['support_tickets_table'] = {
        'status': '✅ PASS',
        'message': 'Support tickets table accessible',
        'total_tickets': data.length,
      };
      print('✅ Support Tickets Table: PASS (${data.length} tickets found)');
    } catch (e) {
      results['support_tickets_table'] = {
        'status': '❌ FAIL',
        'message': 'Support tickets table error: $e',
      };
      print('❌ Support Tickets Table: FAIL - $e');
    }
  }

  static Future<void> testPromotionsTable() async {
    try {
      final data = await SupabaseService.fetch('promotions', limit: 5);
      results['promotions_table'] = {
        'status': '✅ PASS',
        'message': 'Promotions table accessible',
        'total_promotions': data.length,
        'sample_promotion': data.isNotEmpty ? data[0]['name'] : 'No promotions',
      };
      print('✅ Promotions Table: PASS (${data.length} promotions found)');
    } catch (e) {
      results['promotions_table'] = {
        'status': '❌ FAIL',
        'message': 'Promotions table error: $e',
      };
      print('❌ Promotions Table: FAIL - $e');
    }
  }

  static Future<void> testZoneAssignmentsTable() async {
    try {
      final data = await SupabaseService.fetch('zone_assignments', limit: 5);
      results['zone_assignments_table'] = {
        'status': '✅ PASS',
        'message': 'Zone assignments table accessible',
        'total_assignments': data.length,
      };
      print('✅ Zone Assignments Table: PASS (${data.length} assignments found)');
    } catch (e) {
      results['zone_assignments_table'] = {
        'status': '❌ FAIL',
        'message': 'Zone assignments table error: $e',
      };
      print('❌ Zone Assignments Table: FAIL - $e');
    }
  }

  static void printTestSummary() {
    print('\n${'='*60}');
    print('📊 DATABASE CONNECTION TEST SUMMARY');
    print('='*60);

    int passCount = 0;
    int failCount = 0;

    results.forEach((testName, result) {
      if (result['status'].contains('✅')) {
        passCount++;
        print('✅ $testName: ${result['message']}');
      } else {
        failCount++;
        print('❌ $testName: ${result['message']}');
      }
    });

    print('\n${'-'*60}');
    print('📈 RESULTS: $passCount PASS, $failCount FAIL');
    print('🎯 SUCCESS RATE: ${((passCount / (passCount + failCount)) * 100).toStringAsFixed(1)}%');
    print('-'*60);

    if (failCount == 0) {
      print('🎉 ALL TESTS PASSED! Database connections are working perfectly.');
    } else {
      print('⚠️  Some tests failed. Please check the errors above.');
      print('💡 Common fixes:');
      print('   • Verify Supabase URL and keys in config files');
      print('   • Check if database tables exist');
      print('   • Ensure RLS policies allow access');
      print('   • Test network connectivity');
    }
    print('='*60);
  }

  // Test specific screen functionality
  static Future<void> testCustomerHomeScreen() async {
    print('\n🏠 Testing Customer Home Screen Data...');
    
    try {
      // Test water types loading
      final waterTypes = await WaterService.getWaterTypes();
      print('✅ Water types loaded: ${waterTypes.length} found');
      
      // Test user data loading
      final userResponse = await SupabaseService.getCurrentUser();
      if (userResponse['success']) {
        print('✅ User data loaded: ${userResponse['user']['name']}');
      } else {
        print('⚠️  User data not loaded: ${userResponse['message']}');
      }
      
      // Test recent orders
      if (userResponse['success']) {
        final ordersData = await SupabaseService.fetch(
          'orders',
          filters: [
            Filter('customer_id', 'eq', userResponse['user']['id']),
          ],
          orderBy: 'created_at desc',
          limit: 3,
        );
        print('✅ Recent orders loaded: ${ordersData.length} found');
      }
      
      print('✅ Customer Home Screen: All data loading correctly');
    } catch (e) {
      print('❌ Customer Home Screen: $e');
    }
  }

  static Future<void> testAdminDashboard() async {
    print('\n👑 Testing Admin Dashboard Data...');
    
    try {
      // Load dashboard stats
      final usersData = await SupabaseService.fetch('users');
      final ordersData = await SupabaseService.fetch('orders');
      
      int totalUsers = usersData.length;
      int deliveryPartners = usersData.where((u) => u['role'] == 'delivery').length;
      int totalOrders = ordersData.length;
      double revenue = ordersData.fold(0.0, (sum, order) => 
        sum + (order['total_amount'] as num).toDouble());
      
      print('✅ Dashboard stats loaded:');
      print('   • Total Users: $totalUsers');
      print('   • Delivery Partners: $deliveryPartners');
      print('   • Total Orders: $totalOrders');
      print('   • Revenue: TZS ${revenue.toInt()}');
      
      print('✅ Admin Dashboard: All data loading correctly');
    } catch (e) {
      print('❌ Admin Dashboard: $e');
    }
  }
}

// Usage example:
// To run all tests: await DatabaseConnectionTest.runAllTests();
// To test specific screen: await DatabaseConnectionTest.testCustomerHomeScreen();
