# Database Setup Instructions

## Quick Setup Guide

### 1. Access Your Supabase Project
- URL: https://fnqrpyidgshgrwseyvsu.supabase.co
- Navigate to SQL Editor in the dashboard

### 2. Execute Database Schema
1. Copy the entire contents of `supabase_database_schema.sql`
2. Paste it into the SQL Editor
3. Click "Run" to execute the schema creation
4. Wait for all tables to be created (should take 1-2 minutes)

### 3. Execute RLS Policies
1. Copy the entire contents of `supabase_rls_policies.sql`
2. Paste it into the SQL Editor
3. Click "Run" to execute the security policies
4. Verify all policies are created successfully

### 4. Set Up Storage Buckets
1. Go to Storage section in Supabase dashboard
2. Create the following buckets:
   - `profile-images` (public bucket for user avatars)
   - `order-images` (public bucket for order-related images)
   - `documents` (private bucket for delivery partner documents)

3. Set up bucket policies:
   - Profile images: Users can upload/update their own images
   - Order images: Users can access images for their orders
   - Documents: Only authenticated users can access their own documents

### 5. Configure Authentication
1. Go to Authentication > Settings
2. Configure email templates for:
   - Confirm signup
   - Reset password
   - Email change
3. Enable social providers if needed (Google, Apple, etc.)
4. Set site URL to your app's domain

### 6. Test the Setup
1. Run the Flutter app
2. Try to register a new user
3. Verify user appears in the users table
4. Try to place an order
5. Check that all tables are working correctly

### 7. Verify Security
1. Check that RLS is enabled on all tables
2. Test that users can only access their own data
3. Verify admin functions work properly
4. Test delivery partner access controls

## Troubleshooting

### Common Issues
- **Schema errors**: Make sure you run the schema file completely
- **RLS not working**: Verify all policies were created successfully
- **Storage access**: Check bucket policies are set correctly
- **Authentication issues**: Verify Supabase URL and keys in app config

### Getting Help
- Check Supabase logs for errors
- Review the SQL execution results
- Verify all tables were created with correct structure

## Production Checklist

Before going live, ensure:
- [ ] All database tables are created
- [ ] RLS policies are active and working
- [ ] Storage buckets are configured
- [ ] Authentication settings are complete
- [ ] Test data flows work end-to-end
- [ ] Security testing is completed
- [ ] Performance is acceptable
- [ ] Backups are enabled

## Support

If you encounter issues during setup:
1. Check the Supabase dashboard logs
2. Review the SQL execution results
3. Verify your Supabase project URL and keys
4. Contact support through the Supabase dashboard
