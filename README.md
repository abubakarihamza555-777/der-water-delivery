# Water Delivery App

A comprehensive water delivery management application built with Flutter and Supabase.

## Features

### Customer Features
- User registration and authentication
- Address management
- Water type selection and ordering
- Real-time order tracking
- Payment processing
- Order history
- Notifications

### Delivery Partner Features
- Order acceptance and management
- Real-time location tracking
- Navigation support
- Earnings tracking
- Withdrawal management
- Performance analytics

### Admin Features
- User management
- Order management
- Zone configuration
- Payment tracking
- Analytics dashboard
- System settings

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **Google Maps**: Location services and navigation

### Backend
- **Supabase**: Database and authentication
- **PostgreSQL**: Database with PostGIS for geospatial data
- **Row Level Security**: Data access control

### Key Dependencies
- `supabase_flutter`: Supabase integration
- `provider`: State management
- `google_maps_flutter`: Maps integration
- `geolocator`: Location services
- `image_picker`: Image handling

## Database Schema

The app uses a comprehensive PostgreSQL database with the following main tables:

- **users**: User profiles and authentication
- **addresses**: Customer delivery addresses
- **orders**: Order management
- **order_items**: Order line items
- **deliveries**: Delivery tracking
- **payments**: Payment processing
- **transactions**: Financial transactions
- **zones**: Delivery area management
- **notifications**: Push notifications
- **reviews**: Customer feedback

## Security

- **Row Level Security (RLS)**: All tables have RLS policies
- **User Isolation**: Users can only access their own data
- **Role-Based Access**: Different permissions for customers, delivery partners, and admins
- **Secure Authentication**: Supabase Auth with email/password

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd water_delivery_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - The app is pre-configured with Supabase credentials
   - Database schema: `supabase_database_schema.sql`
   - RLS policies: `supabase_rls_policies.sql`

4. **Run the app**
   ```bash
   flutter run
   ```

## Production Deployment

### Database Setup
1. Execute `supabase_database_schema.sql` in Supabase SQL Editor
2. Execute `supabase_rls_policies.sql` for security policies
3. Set up storage buckets for images and documents

### App Deployment
1. Update version in `pubspec.yaml`
2. Build release APK/AAB for Android
3. Build release IPA for iOS
4. Submit to respective app stores

For detailed deployment instructions, see `PRODUCTION_DEPLOYMENT_GUIDE.md`.

## Environment Configuration

The app supports multiple environments:
- **Development**: Local testing
- **Staging**: Pre-production testing
- **Production**: Live deployment

Current configuration is set to **production** mode.

## API Integration

The app uses Supabase for:
- **Authentication**: User signup/login
- **Database**: All data storage
- **Storage**: File uploads
- **Real-time**: Live updates
- **Functions**: Server-side logic

## Testing

### Running Tests
```bash
flutter test
```

### Building for Testing
```bash
flutter build apk --debug
flutter build ios --debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

- **Supabase Dashboard**: https://fnqrpyidgshgrwseyvsu.supabase.co
- **Flutter Documentation**: https://flutter.dev/docs
- **Issue Tracking**: Use GitHub issues

## License

This project is proprietary and confidential.

## Version Information

- **Version**: 1.0.0
- **Build**: 1
- **Last Updated**: April 2026
- **Flutter**: 3.41.6
- **Supabase**: 2.12.4

## Security Notes

- All database connections use HTTPS
- User data is protected by RLS policies
- Authentication tokens are managed by Supabase
- Location data is encrypted in transit
- Payment information is handled securely

## Performance Considerations

- Database queries are optimized with proper indexing
- Image compression for profile pictures
- Efficient state management with Provider
- Lazy loading for large datasets
- Connection pooling handled by Supabase
