# Fix for "Failed to create user profile" Error

## Problem
The error "Failed to create user profile. Please try again." occurs during user signup because the database doesn't have the proper permissions (RLS policies) to allow new users to insert their profile data.

## Root Cause
The `users` table in Supabase has Row Level Security (RLS) enabled but is missing the INSERT policy that allows new users to create their profile during signup.

## Solution Steps

### 1. Run the SQL Fix (REQUIRED)
Execute this SQL script in your Supabase SQL Editor:

```sql
-- Add missing INSERT policy for users table
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);
```

Or run the comprehensive fix script: `comprehensive_user_fix.sql`

### 2. Code Improvements (DONE)
- ✅ Enhanced error handling in AuthProvider
- ✅ More specific error messages for different failure scenarios
- ✅ Better debugging output
- ✅ Cleanup of auth user if profile creation fails

### 3. Testing Steps
1. Run the SQL fix in Supabase
2. Try signing up with a new student account
3. Check the terminal/console for debug messages
4. Verify the user profile is created in the `users` table

## Additional Checks

### Check if RLS Policies Exist
Run this query in Supabase to see current policies:
```sql
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'users';
```

You should see:
- `Users can insert own profile during signup` (INSERT)
- `Users can view own profile` (SELECT)
- `Users can update own profile` (UPDATE)

### Check for Constraint Violations
If you still get errors, check for duplicate student IDs or emails:
```sql
-- Check for duplicate student IDs
SELECT student_id, COUNT(*) FROM users 
WHERE student_id IS NOT NULL 
GROUP BY student_id HAVING COUNT(*) > 1;

-- Check for duplicate emails
SELECT email, COUNT(*) FROM users 
GROUP BY email HAVING COUNT(*) > 1;
```

## Common Error Messages and Solutions

1. **"This student ID is already registered"**
   - Use a unique student ID
   - Check if the student is already registered

2. **"This email is already registered"**
   - Use a different email
   - Try logging in instead of signing up

3. **"Database permission error"**
   - Run the SQL fix script
   - Ensure RLS policies are properly configured

4. **"Network error"**
   - Check internet connection
   - Verify Supabase project is accessible

## Files Modified
- `lib/providers/auth_provider.dart` - Enhanced error handling
- `comprehensive_user_fix.sql` - Database policy fix
- `fix_user_insert_policy.sql` - Simple INSERT policy fix

## Next Steps
After running the SQL fix, the signup process should work correctly. The app will now:
1. Create the auth user in Supabase Auth
2. Create the user profile in the `users` table
3. Navigate to email verification (for students) or success screen (for admins)
