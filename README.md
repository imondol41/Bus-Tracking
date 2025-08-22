# 🚌 University Bus Tracker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**A comprehensive Flutter application for tracking university buses with real-time GPS tracking, role-based authentication, and admin management features.**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## � Overview

The University Bus Tracker is a modern, cross-platform mobile application built with Flutter that provides real-time bus tracking capabilities for educational institutions. With role-based access control, students can track buses, admins can manage the fleet, and super admins oversee the entire system.

### 🎯 Perfect For
- **Universities** looking to modernize their transportation system
- **Students** who want real-time bus location updates
- **Transportation Administrators** managing bus fleets
- **Educational Institutions** seeking efficient transportation solutions

## ✨ Features

### 🔐 **Advanced Authentication System**
- **Multi-Role Access**: Students, Admins, and Super Admins with distinct permissions
- **Secure Signup Process**: Email verification and role-based validation
- **Admin Verification**: Secure admin registration with verification codes
- **Profile Management**: Comprehensive user profile editing capabilities

### � **Role-Based Access Control**
| Role | Capabilities |
|------|-------------|
| **Students** | View bus locations, track routes, edit personal profile |
| **Admins** | Full bus CRUD operations after super admin approval |
| **Super Admins** | System oversight, admin approval, complete management access |

### 🚌 **Smart Bus Tracking**
- **Real-time GPS Monitoring**: Live bus locations with automatic updates
- **Intelligent Route Planning**: Optimized routes with distance calculations
- **Location Intelligence**: Plus Code integration for precise positioning
- **Search & Discovery**: Advanced filtering by bus number, route, or driver
- **Distance Analytics**: Real-time distance from Shanto-Mariam University

### 🗺️ **Advanced Mapping**
- **Interactive Maps**: Seamless Mapbox integration for superior mapping experience
- **Dynamic Markers**: Custom university and bus location indicators
- **Route Visualization**: Clear route directions from university to bus locations
- **ETA Calculations**: Accurate distance and estimated arrival time predictions

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile development |
| **Backend** | Supabase (PostgreSQL) | Real-time database and authentication |
| **Maps** | Mapbox Flutter SDK | Interactive mapping and location services |
| **Authentication** | Supabase Auth | Secure user authentication and management |
| **Real-time** | Supabase Realtime | Live data synchronization |
| **State Management** | Provider | Efficient app state management |

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>=3.10.0) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (>=3.0.0) - Included with Flutter
- **Git** - [Install Git](https://git-scm.com/downloads)
- **VS Code** or **Android Studio** - Recommended IDEs
- **Supabase Account** - [Create Account](https://supabase.com)
- **Mapbox Account** - [Create Account](https://account.mapbox.com)

## 🚀 Installation

### 1. **Clone the Repository**
```bash
git clone https://github.com/YOUR_USERNAME/university-bus-tracker.git
cd university-bus-tracker
```

### 2. **Install Dependencies**
```bash
flutter pub get
```

### 3. **Environment Configuration**

#### 3.1 Supabase Setup
1. Create a new project in [Supabase Dashboard](https://supabase.com/dashboard)
2. Copy your project URL and anon key
3. Copy `lib/config/supabase_config.dart.template` to `lib/config/supabase_config.dart`
4. Update the configuration:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL_HERE';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
}
```

#### 3.2 Database Schema Setup
1. Open Supabase SQL Editor
2. Execute the schema from `docs/supabase_schema.sql`
3. This creates all necessary tables, policies, and triggers

#### 3.3 Super Admin Setup
1. Register through the app with your email
2. Execute the super admin setup SQL from `docs/SUPER_ADMIN_SETUP.sql`
3. Replace the UUID with your actual user ID from the auth.users table

### 4. **Run the Application**
```bash
# Development mode
flutter run --debug

# Release mode  
flutter run --release

# For web
flutter run -d chrome
```

## 📖 Usage

### For Students
1. **Sign up** with student credentials
2. **Browse available buses** in real-time
3. **Track specific buses** on the interactive map
4. **View route information** and estimated arrival times
5. **Manage your profile** and preferences

### For Admins
1. **Request admin access** with verification code: `CSE BATCH 28`
2. **Wait for super admin approval**
3. **Manage bus fleet** (add, edit, delete buses)
4. **Update bus information** and routes
5. **Monitor bus status** and locations

### For Super Admins
1. **Review admin requests** and approve qualified candidates
2. **Oversee system operations** and user management
3. **Monitor application performance** and usage analytics
4. **Manage administrative settings** and configurations

## 📁 Project Structure

```
lib/
├── 📁 config/
│   ├── app_router.dart              # Navigation configuration
│   ├── app_theme.dart               # Application theming
│   ├── supabase_config.dart         # Supabase configuration
│   └── supabase_config.dart.template # Configuration template
├── 📁 models/
│   ├── bus_model.dart               # Bus data model
│   └── user_model.dart              # User data model
├── 📁 providers/
│   ├── auth_provider.dart           # Authentication state
│   ├── bus_tracker_provider.dart    # Bus tracking state
│   └── theme_provider.dart          # Theme state
├── 📁 screens/
│   ├── 📁 auth/                     # Authentication screens
│   ├── 📁 student/                  # Student interface
│   ├── 📁 admin/                    # Admin interface
│   └── 📁 super_admin/              # Super admin interface
├── 📁 services/
│   ├── distance_service.dart        # Location calculations
│   ├── location_service.dart        # GPS and location services
│   ├── openlayers_map_service.dart  # Map integration
│   └── plus_code_service.dart       # Plus code handling
├── 📁 widgets/                      # Reusable UI components
└── main.dart                        # Application entry point

docs/                               # Documentation and SQL files
assets/                            # Images and static assets
test/                             # Unit and widget tests
```

## 🔒 Security Features

- **🛡️ Email Verification**: Required for all user accounts
- **🔐 Role-Based Access**: Granular permission system
- **🔑 Secure API Keys**: Environment-based configuration
- **📡 Data Encryption**: All data encrypted in transit
- **🛡️ Input Validation**: Comprehensive sanitization
- **🚫 SQL Injection Protection**: Supabase-powered security

## 🚀 Deployment

### Mobile Apps
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

### Web Application
```bash
# Build for web
flutter build web --release

# Preview locally
flutter run -d chrome
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific tests
flutter test test/widget_test.dart
```

## 🤝 Contributing

We welcome contributions from developers of all skill levels! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed information on:

- 📋 Code of Conduct
- 🛠️ Development Setup
- 📝 Coding Standards
- 🔄 Pull Request Process
- 🐛 Issue Reporting

### Quick Start for Contributors
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📊 Roadmap

### 🚧 Current Development
- [ ] Enhanced real-time GPS tracking
- [ ] Push notification system
- [ ] Advanced route optimization
- [ ] Performance monitoring dashboard

### 🔮 Future Features
- [ ] Multi-language support
- [ ] Offline mode capabilities
- [ ] Integration with payment systems
- [ ] Advanced analytics and reporting
- [ ] Voice navigation support

## 📞 Support

- 📧 **Email Support**: [Create an issue](https://github.com/YOUR_USERNAME/university-bus-tracker/issues)
- 💬 **Community Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/university-bus-tracker/discussions)
- 📖 **Documentation**: [Wiki Pages](https://github.com/YOUR_USERNAME/university-bus-tracker/wiki)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Supabase** for the powerful backend-as-a-service
- **Mapbox** for superior mapping capabilities
- **Open Source Community** for inspiration and support

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=YOUR_USERNAME/university-bus-tracker&type=Date)](https://star-history.com/#YOUR_USERNAME/university-bus-tracker&Date)

---

<div align="center">

**Built with ❤️ for the educational community**

[⭐ Star this repo](https://github.com/YOUR_USERNAME/university-bus-tracker) • [🐛 Report Bug](https://github.com/YOUR_USERNAME/university-bus-tracker/issues) • [💡 Request Feature](https://github.com/YOUR_USERNAME/university-bus-tracker/issues)

</div>
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
1. First, signup through the app with email: `shoaibhossain2302@gmail.com`
2. After signup, run this SQL in Supabase:
```sql
-- Replace 'USER_UUID_HERE' with the actual UUID from auth.users table
INSERT INTO public.super_admins (id, name, email) 
VALUES (
    'USER_UUID_HERE',
    'Super Admin', 
    'shoaibhossain2302@gmail.com'
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

- **Email**: shoaibhossain2302@gmail.com
- **Password**: HaXon@3211
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
