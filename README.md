# University Bus Tracker

A comprehensive Flutter application for tracking university buses with real-time GPS tracking, role-based authentication, and admin management features.

## Features

### 🔐 Authentication System
- **Student Signup**: Full registration with student details
- **Admin Signup**: Requires verification code "CSE BATCH 28" and super admin approval
- **Super Admin**: Manual setup with login-only access
- **Role-based Access Control**: Different interfaces for students, admins, and super admins

### 👤 User Roles
- **Students**: View and track buses, edit profile
- **Admins**: Manage buses (CRUD operations) after super admin approval
- **Super Admins**: Approve admin requests, manage admins, system oversight

### 🚌 Bus Tracking
- **Real-time GPS Tracking**: Live bus locations using Mapbox
- **Route Information**: Bus routes, driver details, and location names
- **Distance Calculation**: Distance from Shanto-Mariam University
- **Search & Filter**: Find buses by number, route, or driver
- **Plus Code Support**: Google Plus Code integration

### 🗺️ Mapbox Integration
- **Interactive Maps**: Real-time bus locations
- **Route Directions**: From university to bus locations
- **Custom Markers**: University and bus location markers
- **Distance & ETA**: Real-time distance and estimated time calculations

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL)
- **Maps**: Mapbox Flutter SDK
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime
- **State Management**: Provider

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Supabase Account
- Mapbox Account

### 1. Clone the Repository
```bash
git clone <repository-url>
cd university_bus_tracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Supabase Setup

#### 3.1 Create Supabase Project
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project
3. Copy your project URL and anon key

#### 3.2 Configure Supabase
1. Update `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL_HERE';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
}
```

#### 3.3 Run Database Schema
1. Open Supabase SQL Editor
2. Copy and paste the content from `supabase_schema.sql`
3. Execute the script to create all tables and policies

#### 3.4 Setup Super Admin
1. First, signup through the app with email: `imondol41@gmail.com`
2. After signup, run this SQL in Supabase:
```sql
-- Replace 'USER_UUID_HERE' with the actual UUID from auth.users table
INSERT INTO public.super_admins (id, name, email) 
VALUES (
    'USER_UUID_HERE',
    'Super Admin', 
    'imondol41@gmail.com'
);
```

### 4. Mapbox Setup

#### 4.1 Get Mapbox API Key
1. Go to [Mapbox Account](https://account.mapbox.com/)
2. Create a new access token or use existing
3. The current API key in the app: `pk.eyJ1IjoiaGF4b24iLCJhIjoiY21jc3V1eXlrMGxnNzJtczd2eHp4MWdjNyJ9.7rz1vdK8E18eFZLiO2IxZQ`

#### 4.2 Configure Mapbox (Future Enhancement)
The current implementation shows a placeholder for Mapbox integration. To fully integrate:

1. Add Mapbox configuration in `pubspec.yaml`
2. Update map screens to use actual Mapbox widgets
3. Implement real-time GPS tracking

### 5. Run the Application
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   ├── app_router.dart          # Navigation configuration
│   ├── app_theme.dart           # App theming
│   └── supabase_config.dart     # Supabase configuration
├── models/
│   ├── bus_model.dart           # Bus data model
│   └── user_model.dart          # User data model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── bus_tracker_provider.dart # Bus tracking state management
│   └── theme_provider.dart      # Theme state management
├── screens/
│   ├── auth/
│   │   ├── auth_checker_screen.dart # Authentication routing
│   │   ├── login_screen.dart        # Login interface
│   │   └── signup_screen.dart       # Registration interface
│   ├── student/
│   │   ├── dashboard_screen.dart    # Student dashboard
│   │   ├── map_tracker_screen.dart  # Bus tracking interface
│   │   └── profile_screen.dart      # Profile management
│   ├── admin/
│   │   ├── admin_panel_screen.dart  # Admin dashboard
│   │   └── bus_form_screen.dart     # Bus CRUD operations
│   └── super_admin/
│       └── super_admin_panel_screen.dart # Super admin dashboard
└── main.dart                    # App entry point
```

## Database Schema

### Tables
- **users**: Student profiles and information
- **admin_requests**: Pending admin approval requests
- **admins**: Approved admin accounts
- **super_admins**: Super administrator accounts
- **buses**: Bus information and GPS tracking data

### Key Features
- Row Level Security (RLS) for data protection
- Real-time subscriptions for live updates
- Automatic timestamp management
- Role-based access policies

## Default Locations

- **University**: Shanto-Mariam University (23.7489, 90.3708)
- **Plus Code**: R9XC+F9 Dhaka
- **Default Routes**: Dhaka to Savar, University Campus routes

## Admin Verification Code

- **Code**: `CSE BATCH 28`
- **Purpose**: Hidden verification for admin signup
- **Access**: Required before admin registration form

## Super Admin Credentials

- **Email**: imondol41@gmail.com
- **Password**: 123456
- **Setup**: Manual insertion in database required

## API Integrations

### Mapbox API Key
```
pk.eyJ1IjoiaGF4b24iLCJhIjoiY21jc3V1eXlrMGxnNzJtczd2eHp4MWdjNyJ9.7rz1vdK8E18eFZLiO2IxZQ
```

### Supabase Features Used
- Authentication with email/password
- Real-time database subscriptions
- Row Level Security (RLS)
- PostgreSQL with JSON support
- File storage (for future profile pictures)

## Development Status

### ✅ Completed Features
- Complete authentication system
- Role-based access control
- Bus CRUD operations
- Real-time data synchronization
- Admin approval workflow
- Theme management
- Responsive UI design

### 🚧 In Progress / Future Enhancements
- Full Mapbox integration with live maps
- Real-time GPS tracking
- Push notifications
- File upload for profile pictures
- Advanced analytics
- Route optimization
- Bus scheduling system

## Deployment

### For Development
```bash
flutter run --debug
```

### For Production
```bash
flutter build apk --release
flutter build ios --release
```

## Security Features

- Email verification required
- Role-based access control
- Secure API keys
- Data encryption in transit
- Input validation and sanitization
- SQL injection protection via Supabase

## Support & Contact

For technical support or feature requests, please contact the development team.

## License

This project is developed for educational purposes for Shanto-Mariam University.

---

**Note**: This application is designed specifically for Shanto-Mariam University's bus tracking needs. Modify configurations and branding as needed for other institutions.
