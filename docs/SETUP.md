# University Bus Tracker - Complete Setup Guide

This comprehensive guide will walk you through setting up the University Bus Tracker application step by step.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Supabase Configuration](#supabase-configuration)
5. [Platform-Specific Setup](#platform-specific-setup)
6. [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/YOUR_USERNAME/university-bus-tracker.git
cd university-bus-tracker

# 2. Install Flutter dependencies
flutter pub get

# 3. Check Flutter doctor
flutter doctor

# 4. Copy config template
cp lib/config/supabase_config.dart.template lib/config/supabase_config.dart

# 5. Configure Supabase (see detailed instructions below)
# Edit lib/config/supabase_config.dart with your credentials

# 6. Run the app
flutter run
```

## Prerequisites

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.14+, or Ubuntu 18.04+
- **RAM**: Minimum 8GB (16GB recommended for optimal performance)
- **Storage**: At least 10GB free space
- **Network**: Stable internet connection for Supabase and map services

### Required Software

1. **Flutter SDK 3.10.0+**
   ```bash
   flutter --version
   flutter doctor
   ```

2. **Git** for version control
   ```bash
   git --version
   ```

3. **Code Editor** (VS Code recommended with Flutter extensions)
2. Create new account or sign in
3. Click "New Project"
4. Fill project details:
   - Name: `university-bus-tracker`
   - Organization: Your organization
   - Database Password: Choose a strong password
   - Region: Choose closest to your location

#### 3.2 Get Supabase Credentials
1. In your Supabase dashboard, go to Settings > API
2. Copy these values:
   - Project URL
   - Project API Keys > anon public

#### 3.3 Configure Flutter App
Edit `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://your-project-ref.supabase.co';
  static const String anonKey = 'your-anon-key-here';
}
```

#### 3.4 Setup Database Schema
1. In Supabase dashboard, go to SQL Editor
2. Open `supabase_schema.sql` from project root
3. Copy all content and paste in SQL Editor
4. Click "Run" to execute

This creates:
- All necessary tables (users, admins, buses, etc.)
- Row Level Security policies
- Indexes for performance
- Triggers for automatic updates

### Step 4: Authentication Setup

#### 4.1 Enable Email Authentication
1. In Supabase dashboard, go to Authentication > Settings
2. Ensure Email is enabled
3. Configure email templates (optional)
4. Set site URL to your app's URL

#### 4.2 Create Super Admin Account
1. Run the Flutter app: `flutter run`
2. Navigate to signup screen
3. Create account with email: `shoaibhossain2302@gmail.com`
4. After signup, go to Supabase dashboard > Authentication > Users
5. Copy the User ID of the created user
6. In SQL Editor, run:

```sql
INSERT INTO public.super_admins (id, name, email) 
VALUES (
    'paste-user-id-here',
    'Super Admin', 
    'shoaibhossain2302@gmail.com'
);
```

### Step 5: Mapbox Integration

#### 5.1 Current Status
The app currently uses a placeholder for Mapbox integration. The provided API key is:
```
pk.eyJ1IjoiaGF4b24iLCJhIjoiY21jc3V1eXlrMGxnNzJtczd2eHp4MWdjNyJ9.7rz1vdK8E18eFZLiO2IxZQ
```

#### 5.2 For Full Integration (Optional)
1. Create Mapbox account at [mapbox.com](https://mapbox.com)
2. Generate access token
3. Replace the token in the code
4. Update map screens to use actual Mapbox widgets

### Step 6: Platform-Specific Setup

#### 6.1 Android Setup
1. Update `android/app/src/main/AndroidManifest.xml` (already configured)
2. Ensure minimum SDK version is 21+
3. Add location permissions (already added)

#### 6.2 iOS Setup (if targeting iOS)
1. Update `ios/Runner/Info.plist` with location permissions
2. Configure Mapbox if using real integration
3. Set minimum iOS version to 11.0+

### Step 7: Running the Application

#### 7.1 Development Mode
```bash
flutter run
```

#### 7.2 Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d device-id
```

#### 7.3 Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Step 8: Testing the App

#### 8.1 Test User Accounts

**Super Admin:**
- Email: `shoaibhossain2302@gmail.com`
- Password: `HaXon@3211`

**Admin Signup:**
- Verification Code: `CSE BATCH 28`
- Requires super admin approval after signup

**Student Signup:**
- Direct registration
- Immediate access after email verification

#### 8.2 Test Bus Data
1. Login as super admin
2. Switch to admin panel (or create admin account)
3. Add test buses:
   - Bus Number: `101`
   - Route: `Dhaka to Savar`
   - Driver: `Test Driver`
   - Latitude: `23.7489` (University location)
   - Longitude: `90.3708`

### Step 9: Troubleshooting

#### 9.1 Common Issues

**Supabase Connection Error:**
- Check internet connection
- Verify Supabase credentials
- Ensure Supabase project is active

**Build Errors:**
```bash
flutter clean
flutter pub get
flutter run
```

**Package Conflicts:**
```bash
flutter pub deps
flutter pub upgrade
```

#### 9.2 Debug Commands
```bash
# Check Flutter setup
flutter doctor -v

# Analyze code
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub deps
```

### Step 10: Production Deployment

#### 10.1 Build APK (Android)
```bash
flutter build apk --release
```

#### 10.2 Build App Bundle (Android - Recommended)
```bash
flutter build appbundle --release
```

#### 10.3 Build iOS (macOS only)
```bash
flutter build ios --release
```

### Step 11: Environment Variables (Recommended)

For production, create environment-specific configurations:

1. Create `lib/config/env.dart`:
```dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String mapboxApiKey = String.fromEnvironment('MAPBOX_API_KEY');
}
```

2. Run with environment variables:
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

## Support

For issues or questions:
1. Check the README.md file
2. Review Supabase documentation
3. Check Flutter documentation
4. Contact the development team

## Next Steps

After successful setup:
1. Customize the app branding
2. Add real bus data
3. Test with multiple users
4. Configure push notifications
5. Set up production deployment
6. Monitor usage and performance

---

**Note**: This setup creates a fully functional bus tracking system. Customize as needed for your specific university requirements.
