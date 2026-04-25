class SupabaseConfig {
  static const String supabaseUrl = 'https://fqvdqspdqyfeblxgjozz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdmRxc3BkcXlmZWJseGdqb3p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNDYyNjEsImV4cCI6MjA5MjYyMjI2MX0.EbUpbwbzsArIjmPHU7RVNVK6N9Fq9sUfmXCXbGuc4x0';
  
  // Database tables
  static const String usersTable = 'users';
  static const String addressesTable = 'addresses';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String deliveriesTable = 'deliveries';
  static const String zonesTable = 'zones';
  static const String paymentsTable = 'payments';
  static const String transactionsTable = 'transactions';
  static const String notificationsTable = 'notifications';
  static const String reviewsTable = 'reviews';
  static const String waterTypesTable = 'water_types';
  static const String zoneAssignmentsTable = 'zone_assignments';
  static const String withdrawalRequestsTable = 'withdrawal_requests';
  static const String supportTicketsTable = 'support_tickets';
  static const String promotionsTable = 'promotions';
  static const String promotionUsageTable = 'promotion_usage';
  
  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String orderImagesBucket = 'order-images';
  static const String documentsBucket = 'documents';
}
