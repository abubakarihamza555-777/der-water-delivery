# Database Setup Guide - New Project

## Overview
This guide will help you set up the new clean database for the Water Delivery App.

## New Database Details
- **URL**: https://fqvdqspdqyfeblxgjozz.supabase.co
- **Anon Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdmRxc3BkcXlmZWJseGdqb3p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNDYyNjEsImV4cCI6MjA5MjYyMjI2MX0.EbUpbwbzsArIjmPHU7RVNVK6N9Fq9sUfmXCXbGuc4x0

## Setup Instructions

### Step 1: Access Supabase Dashboard
1. Go to: https://fqvdqspdqyfeblxgjozz.supabase.co
2. Navigate to the SQL Editor

### Step 2: Execute Scripts in Order
Run these SQL scripts in the exact order:

1. **database_schema.sql** - Creates all tables, types, indexes, and functions
2. **rls_policies.sql** - Sets up Row Level Security policies
3. **database_init.sql** - Inserts essential data only

### Step 3: Verify Setup
After running all scripts, verify the setup:

```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check essential data
SELECT COUNT(*) as water_types FROM water_types WHERE is_active = true;
SELECT COUNT(*) as zones FROM zones WHERE is_active = true;
SELECT COUNT(*) as admin_users FROM users WHERE role = 'admin';
```

### Step 4: Set Admin Password
1. Go to Authentication → Users in Supabase Dashboard
2. Find the admin user (admin@darwaterdelivery.com)
3. Set a secure password

### Step 5: Configure Storage (Optional)
Create storage buckets if needed:
- profile-images
- order-images  
- documents

## Database Schema Summary

### Core Tables
- **users** - User accounts (customers, delivery partners, admins)
- **addresses** - Delivery addresses
- **water_types** - Product catalog
- **orders** - Customer orders
- **order_items** - Order line items
- **deliveries** - Delivery tracking
- **payments** - Payment processing
- **transactions** - Financial transactions

### Supporting Tables
- **zones** - Delivery areas
- **zone_assignments** - Delivery partner zone assignments
- **notifications** - System notifications
- **reviews** - Customer feedback
- **withdrawal_requests** - Withdrawal processing
- **support_tickets** - Customer support
- **promotions** - Discount codes
- **promotion_usage** - Promotion tracking

## Security Features
- Row Level Security (RLS) enabled on all tables
- Role-based access control
- Secure views for sensitive data
- Audit triggers for critical operations

## No Sample Data
This database contains only essential operational data:
- 3 basic water types
- 4 delivery zones for Dar es Salaam
- 1 system admin account
- No customer orders, users, or transactions

## Testing the App
After setup:
1. Register a new customer account
2. Add a delivery address
3. Place a test order
4. Verify all features work correctly

## Troubleshooting

### Common Issues
1. **"relation does not exist"** - Run scripts in correct order
2. **"permission denied"** - Check RLS policies are applied
3. **"function does not exist"** - Ensure schema script completed successfully

### Getting Help
- Check Supabase logs for errors
- Verify all scripts ran without errors
- Contact support through Supabase dashboard

## Configuration Files Updated
- `lib/config/supabase_config.dart` - Updated with new URL and keys
- `lib/config/app_config.dart` - Updated with new URL and keys
- All table references verified and corrected

## Production Ready
The database is now clean, secure, and ready for production use with the new Supabase project.
