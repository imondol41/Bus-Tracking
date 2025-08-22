import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_currentUser != null) {
        print('DEBUG: Loading profile for user: ${_currentUser!.id}');
        
        // First check if user is in users table (students)
        try {
          final response = await _supabase
              .from('users')
              .select()
              .eq('id', _currentUser!.id);
              
          if (response.isNotEmpty) {
            _userProfile = UserModel.fromJson(response.first);
            notifyListeners();
            return;
          }
        } catch (e) {
          print('Error checking users table: $e');
        }

        // Then check if user is in admins table
        try {
          final response = await _supabase
              .from('admins')
              .select()
              .eq('id', _currentUser!.id);
              
          if (response.isNotEmpty) {
            _userProfile = UserModel.fromJson({
              ...response.first,
              'role': 'admin',
            });
            notifyListeners();
            return;
          }
        } catch (e) {
          print('Error checking admins table: $e');
        }

        // Check if user is in super_admins table
        try {
          final response = await _supabase
              .from('super_admins')
              .select()
              .eq('id', _currentUser!.id);
              
          if (response.isNotEmpty) {
            _userProfile = UserModel.fromJson({
              ...response.first,
              'role': 'super_admin',
            });
            notifyListeners();
            return;
          }
        } catch (e) {
          print('Error checking super_admins table: $e');
        }
        
        print('DEBUG: User profile not found in any table');
        _userProfile = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user profile: $e');
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Add a function to check if email or student ID already exists
  Future<Map<String, bool>> checkExistingUserData({
    required String email,
    String? studentId,
  }) async {
    try {
      // Check email in users table
      final emailCheck = await _supabase
          .from('users')
          .select('email')
          .eq('email', email);
      
      // Check student ID in users table (if provided)
      bool studentIdExists = false;
      if (studentId != null && studentId.isNotEmpty) {
        final studentIdCheck = await _supabase
            .from('users')
            .select('student_id')
            .eq('student_id', studentId);
        studentIdExists = studentIdCheck.isNotEmpty;
      }
      
      return {
        'emailExists': emailCheck.isNotEmpty,
        'studentIdExists': studentIdExists,
      };
    } catch (e) {
      print('Error checking existing user data: $e');
      return {
        'emailExists': false,
        'studentIdExists': false,
      };
    }
  }

  Future<bool> signUpStudent({
    required String name,
    required String studentId,
    required String email,
    required String password,
    required String department,
    required String semester,
    required String batch,
    required String contactNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check for existing data first
      final existingCheck = await checkExistingUserData(
        email: email,
        studentId: studentId,
      );

      if (existingCheck['emailExists'] == true) {
        _setError('This email address is already registered. Please use a different email or try logging in instead.');
        _setLoading(false);
        return false;
      }

      if (existingCheck['studentIdExists'] == true) {
        _setError('This Student ID is already registered. Please use a different Student ID or contact support if this is your ID.');
        _setLoading(false);
        return false;
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email redirect, use OTP instead
      );

      print('DEBUG: Auth signup response: ${response.user?.id}');

      if (response.user != null) {
        // Create user profile - ensure this step succeeds
        try {
          print('DEBUG: Creating user profile in database');
          print('DEBUG: User ID: ${response.user!.id}');
          print('DEBUG: Email: $email');
          print('DEBUG: Student ID: $studentId');
          
          final insertData = {
            'id': response.user!.id,
            'name': name,
            'student_id': studentId,
            'email': email,
            'department': department,
            'semester': semester,
            'batch': batch,
            'contact_number': contactNumber,
            'role': 'student',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          print('DEBUG: Insert data: $insertData');
          
          // Use RPC function to bypass RLS during signup
          await _supabase.rpc('create_user_profile', params: insertData);
          
          print('DEBUG: User profile created successfully via RPC');
          
          // The RPC function handles the insert with SECURITY DEFINER
          // No need to verify since the RPC would throw an error if it failed
          
        } catch (profileError) {
          print('DEBUG: User profile creation failed: $profileError');
          
          // Provide more specific error messages based on the error
          String errorMessage = 'Failed to create user profile. Please try again.';
          
          // Check for duplicate key violations
          if (profileError.toString().toLowerCase().contains('duplicate key value') || 
              profileError.toString().toLowerCase().contains('unique constraint')) {
            
            if (profileError.toString().toLowerCase().contains('student_id') || 
                profileError.toString().toLowerCase().contains('users_student_id_key')) {
              errorMessage = 'This Student ID is already registered. Please use a different Student ID or contact support if this is your ID.';
            } else if (profileError.toString().toLowerCase().contains('email') || 
                       profileError.toString().toLowerCase().contains('users_email_key')) {
              errorMessage = 'This email address is already registered. Please use a different email or try logging in instead.';
            } else {
              errorMessage = 'This information is already registered. Please check your Student ID and email address.';
            }
            
          } else if (profileError.toString().toLowerCase().contains('permission denied') || 
                     profileError.toString().toLowerCase().contains('rls') ||
                     profileError.toString().toLowerCase().contains('policy')) {
            errorMessage = 'Database permission error. Please contact support or try again later.';
          } else if (profileError.toString().toLowerCase().contains('timeout') || 
                     profileError.toString().toLowerCase().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection and try again.';
          }
          
          // Clean up the auth user if profile creation failed
          try {
            await _supabase.auth.signOut();
          } catch (cleanupError) {
            print('DEBUG: Cleanup failed: $cleanupError');
          }
          
          _setError(errorMessage);
          _setLoading(false);
          return false;
        }
        
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Student signup error: $e');
      
      String errorMessage = 'Student signup failed. Please try again.';
      if (e.toString().toLowerCase().contains('user already registered') || 
          e.toString().toLowerCase().contains('email already exists')) {
        errorMessage = 'An account with this email address already exists. Please try logging in instead.';
      } else if (e.toString().toLowerCase().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().toLowerCase().contains('password')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (e.toString().toLowerCase().contains('network') || 
                 e.toString().toLowerCase().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyEmailWithOTP({
    required String email,
    required String token,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      String errorMessage;
      if (e.message.toLowerCase().contains('expired') || 
          e.message.toLowerCase().contains('invalid') ||
          e.statusCode == '403') {
        errorMessage = 'The verification code has expired or is invalid. Please request a new code.';
      } else if (e.message.toLowerCase().contains('too many requests')) {
        errorMessage = 'Too many attempts. Please wait a few minutes before trying again.';
      } else {
        errorMessage = e.message;
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Verification failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOTP({
    required String email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      String errorMessage;
      if (e.message.toLowerCase().contains('too many requests')) {
        errorMessage = 'Too many requests. Please wait a few minutes before requesting a new code.';
      } else if (e.message.toLowerCase().contains('not found')) {
        errorMessage = 'Email not found. Please sign up again.';
      } else {
        errorMessage = e.message;
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to resend verification code. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpAdmin({
    required String name,
    required String email,
    required String password,
    required String department,
    required String contactNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if email already exists in auth or admin requests
      final existingCheck = await checkExistingUserData(email: email);
      if (existingCheck['emailExists'] == true) {
        _setError('This email address is already registered. Please use a different email or try logging in instead.');
        _setLoading(false);
        return false;
      }

      // Check if admin request already exists
      final adminRequestCheck = await _supabase
          .from('admin_requests')
          .select('email')
          .eq('email', email);

      if (adminRequestCheck.isNotEmpty) {
        _setError('An admin request with this email address is already pending approval. Please wait for approval or contact support.');
        _setLoading(false);
        return false;
      }

      // Check if already an admin
      final adminCheck = await _supabase
          .from('admins')
          .select('email')
          .eq('email', email);

      if (adminCheck.isNotEmpty) {
        _setError('This email address is already registered as an admin. Please try logging in instead.');
        _setLoading(false);
        return false;
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create admin request (pending approval)
        try {
          await _supabase.from('admin_requests').insert({
            'id': response.user!.id,
            'name': name,
            'email': email,
            'department': department,
            'contact_number': contactNumber,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });

          _setLoading(false);
          return true;
        } catch (adminRequestError) {
          print('DEBUG: Admin request creation failed: $adminRequestError');
          
          // Clean up auth user if admin request creation fails
          try {
            await _supabase.auth.signOut();
          } catch (cleanupError) {
            print('DEBUG: Cleanup failed: $cleanupError');
          }
          
          String errorMessage = 'Failed to submit admin request. Please try again.';
          if (adminRequestError.toString().toLowerCase().contains('duplicate key value') ||
              adminRequestError.toString().toLowerCase().contains('unique constraint')) {
            errorMessage = 'An admin request with this information already exists. Please contact support.';
          }
          
          _setError(errorMessage);
          _setLoading(false);
          return false;
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Admin signup error: $e');
      
      String errorMessage = 'Admin signup failed. Please try again.';
      if (e.toString().toLowerCase().contains('user already registered') || 
          e.toString().toLowerCase().contains('email already exists')) {
        errorMessage = 'An account with this email address already exists. Please try logging in instead.';
      } else if (e.toString().toLowerCase().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> getUserRole() async {
    if (_currentUser == null) return 'none';

    try {
      print('DEBUG: Checking role for user ID: ${_currentUser!.id}');
      
      // Check super_admins table first
      final superAdminResponse = await _supabase
          .from('super_admins')
          .select()
          .eq('id', _currentUser!.id);
      
      if (superAdminResponse.isNotEmpty) {
        print('DEBUG: Found super admin role');
        return 'super_admin';
      }

      // Check admins table
      try {
        final adminResponse = 
          await _supabase.from('admins').select().eq('id', _currentUser!.id);
        
        if (adminResponse.isNotEmpty) {
          print('DEBUG: Found admin role');
          return 'admin';
        }
      } catch (e) {
        print('DEBUG: Error checking admin role: $e');
      }

      // Check users table
      try {
        final userResponse = 
          await _supabase.from('users').select().eq('id', _currentUser!.id);
        
        if (userResponse.isNotEmpty) {
          print('DEBUG: Found student role');
          return 'student';
        }
      } catch (e) {
        print('DEBUG: Error checking student role: $e');
      }

      // Check if email is confirmed but no role found
      if (_currentUser!.emailConfirmedAt != null) {
        print('DEBUG: Email confirmed but no role found - unverified user');
        return 'unverified';
      }

      print('DEBUG: No role found for user');
      return 'unverified';
    } catch (e) {
      print('Error getting user role: $e');
      return 'none';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}