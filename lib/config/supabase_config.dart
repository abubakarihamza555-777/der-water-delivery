class SupabaseConfig {
  static const String supabaseUrl = 'https://fnqrpyidgshgrwseyvsu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucXJweWlkZ3NoZ3J3c2V5dnN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4MjE3NzQsImV4cCI6MjA5MjM5Nzc3NH0.eEj-3_60il4zC8HrmaHmZEPmKfvBQQx1i9lyU97DvGY';
  
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
  static const String deliveryPartnersTable = 'delivery_partners';
  
  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String orderImagesBucket = 'order-images';
  static const String documentsBucket = 'documents';
}
