import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/auth_checker_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/student/dashboard_screen.dart';
import '../screens/student/map_tracker_screen.dart';
import '../screens/student/profile_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/admin/bus_form_screen.dart';
import '../screens/super_admin/super_admin_panel_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthCheckerScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final userType = state.uri.queryParameters['userType'] ?? 'student';
          return OTPVerificationScreen(
            email: email,
            userType: userType,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapTrackerScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/admin/bus-form',
        builder: (context, state) => const BusFormScreen(),
      ),
      GoRoute(
        path: '/admin/bus-form/:busId',
        builder: (context, state) {
          final busId = state.pathParameters['busId'];
          return BusFormScreen(busId: busId);
        },
      ),
      GoRoute(
        path: '/super-admin',
        builder: (context, state) => const SuperAdminPanelScreen(),
      ),
    ],
  );
}
