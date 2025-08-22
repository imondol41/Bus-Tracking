// DEBUGGING: Add this method to your AuthProvider class to get more detailed error info

Future<void> debugSignupIssue({
  required String email,
  required String studentId,
}) async {
  try {
    print('=== DEBUGGING SIGNUP ISSUE ===');
    
    // Test 1: Check if we can connect to Supabase
    print('1. Testing Supabase connection...');
    try {
      final testQuery = await _supabase.from('users').select('count').limit(1);
      print('   ✅ Supabase connection successful');
    } catch (e) {
      print('   ❌ Supabase connection failed: $e');
      return;
    }
    
    // Test 2: Check current auth state
    print('2. Checking auth state...');
    final currentUser = _supabase.auth.currentUser;
    print('   Current user: ${currentUser?.id ?? 'No user'}');
    
    // Test 3: Try a simple auth signup (no profile creation)
    print('3. Testing auth signup...');
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: 'test123456', // Use a test password
      );
      print('   ✅ Auth signup successful: ${response.user?.id}');
      
      if (response.user != null) {
        // Test 4: Try to insert profile
        print('4. Testing profile insertion...');
        try {
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'name': 'Test User',
            'student_id': studentId,
            'email': email,
            'department': 'Test Dept',
            'semester': '1st',
            'batch': '2025',
            'contact_number': '1234567890',
            'role': 'student',
          });
          print('   ✅ Profile insertion successful');
          
          // Clean up test user
          await _supabase.auth.signOut();
          print('   ✅ Test user cleaned up');
          
        } catch (profileError) {
          print('   ❌ Profile insertion failed: $profileError');
          
          // Clean up auth user
          await _supabase.auth.signOut();
          
          // Check what specific error occurred
          if (profileError.toString().contains('permission denied') ||
              profileError.toString().contains('policy')) {
            print('   💡 SOLUTION: Run the SQL fix in Supabase to add INSERT policy');
          } else if (profileError.toString().contains('duplicate key')) {
            print('   💡 SOLUTION: User already exists, try different email/student ID');
          } else {
            print('   💡 UNKNOWN ERROR: $profileError');
          }
        }
      }
    } catch (authError) {
      print('   ❌ Auth signup failed: $authError');
      
      if (authError.toString().contains('User already registered')) {
        print('   💡 SOLUTION: User already exists, try different email');
      }
    }
    
    print('=== DEBUGGING COMPLETE ===');
    
  } catch (e) {
    print('❌ Debug failed: $e');
  }
}

// Call this method in your signup screen to debug the issue
// await authProvider.debugSignupIssue(email: 'test@example.com', studentId: 'TEST123');
