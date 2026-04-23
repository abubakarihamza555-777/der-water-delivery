# Water Delivery App - Production Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the Water Delivery App to production with Supabase backend.

## Prerequisites
- Flutter SDK 3.0.0 or higher
- Android Studio / VS Code
- Supabase account with project set up
- Google Play Console account (for Android)
- Apple App Store account (for iOS)

## 1. Database Setup

### 1.1 Execute Database Schema
1. Go to your Supabase project: https://fnqrpyidgshgrwseyvsu.supabase.co
2. Navigate to SQL Editor
3. Execute the `supabase_database_schema.sql` file
4. Execute the `supabase_rls_policies.sql` file

### 1.2 Configure Storage Buckets
Create the following storage buckets with appropriate policies:
- `profile-images` - User profile pictures
- `order-images` - Order-related images
- `documents` - Delivery partner documents

### 1.3 Set Up Authentication
1. Go to Authentication > Settings
2. Configure email templates
3. Set up social providers if needed
4. Configure URL redirects for mobile app

## 2. App Configuration

### 2.1 Environment Configuration
The app is already configured for production in `lib/config/app_config.dart`:
- Environment is set to `production`
- Supabase URL and keys are configured

### 2.2 Build Configuration

#### Android Production Build
```bash
# Clean project
flutter clean
flutter pub get

# Build APK for release
flutter build apk --release --no-shrink

# Build App Bundle for Play Store
flutter build appbundle --release
```

#### iOS Production Build
```bash
# Clean project
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release
```

## 3. Security Configuration

### 3.1 API Keys
- Supabase keys are embedded in the app (safe for client-side)
- No sensitive server-side keys are included
- Row Level Security (RLS) is enabled on all tables

### 3.2 Network Security
- All API calls go through Supabase
- HTTPS is enforced by Supabase
- RLS policies ensure data access control

## 4. Testing Before Deployment

### 4.1 Functional Testing
- User registration and login
- Order placement and tracking
- Delivery partner functionality
- Admin dashboard access
- Payment processing

### 4.2 Integration Testing
- Real Supabase connection
- Push notifications
- Location services
- Payment gateway integration

## 5. Deployment Steps

### 5.1 Google Play Store
1. Update version in `pubspec.yaml` if needed
2. Generate signed APK/AAB
3. Create listing in Google Play Console
4. Upload build files
5. Complete store listing information
6. Submit for review

### 5.2 Apple App Store
1. Update version in `pubspec.yaml` and `Info.plist`
2. Build iOS release
3. Create app listing in App Store Connect
4. Upload build via Xcode or Transporter
5. Complete app information
6. Submit for review

## 6. Post-Deployment

### 6.1 Monitoring
- Set up crash reporting (Firebase Crashlytics recommended)
- Monitor Supabase logs
- Track app performance

### 6.2 Analytics
- Enable analytics in Supabase
- Set up custom events tracking
- Monitor user behavior

### 6.3 Notifications
- Configure FCM for Android push notifications
- Configure APNs for iOS push notifications
- Test notification delivery

## 7. Maintenance

### 7.1 Database Backups
- Enable automatic backups in Supabase
- Set up point-in-time recovery
- Regular backup verification

### 7.2 Updates
- Plan regular app updates
- Database schema migrations
- Feature rollouts

## 8. Troubleshooting

### 8.1 Common Issues
- **Build failures**: Run `flutter clean` and try again
- **Authentication errors**: Verify Supabase configuration
- **Database connection**: Check RLS policies
- **Push notifications**: Verify FCM/APNs setup

### 8.2 Support
- Supabase dashboard: https://fnqrpyidgshgrwseyvsu.supabase.co
- Flutter documentation: https://flutter.dev/docs
- App issues: Check logs and error reporting

## 9. Security Best Practices

### 9.1 Data Protection
- All data is protected by RLS policies
- Users can only access their own data
- Admin access is properly restricted

### 9.2 Privacy Compliance
- User data is encrypted in transit
- Local data storage is minimized
- User consent is obtained for necessary permissions

## 10. Performance Optimization

### 10.1 App Performance
- Image optimization for profile pictures
- Efficient data loading with pagination
- Proper state management

### 10.2 Database Performance
- Proper indexing on all tables
- Query optimization
- Connection pooling (handled by Supabase)

## Contact Information
- **Supabase Project**: https://fnqrpyidgshgrwseyvsu.supabase.co
- **Support**: Check app logs and Supabase dashboard for issues

## Version Information
- **App Version**: 1.0.0
- **Flutter Version**: 3.0.0+
- **Supabase Flutter SDK**: 2.0.2+
- **Last Updated**: April 2026
