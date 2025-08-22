# TROUBLESHOOTING: "Failed to create user profile" Error

## Quick Fix Steps

### 1. FIRST - Run SQL Fix in Supabase (REQUIRED)
1. Go to your Supabase project dashboard
2. Click on "SQL Editor"
3. Run this query:

```sql
-- Check what policies exist first
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'users';
```

If you see no results or missing INSERT policy, run:

```sql
-- Add the missing INSERT policy
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);
```

### 2. Check Debug Output
When you try to signup, check your Flutter console/terminal for debug messages like:
- `DEBUG: Starting student signup for email: ...`
- `DEBUG: Auth signup response: ...`  
- `DEBUG: Creating user profile in database`
- `DEBUG: User profile creation failed: ...`

### 3. Common Error Patterns & Solutions

#### Error: "permission denied for table users"
**Solution**: RLS policy missing - run the SQL fix above

#### Error: "duplicate key value violates unique constraint"
**Solutions**: 
- Try different email address
- Try different student ID
- Check if user already exists

#### Error: "null value in column violates not-null constraint"
**Solution**: Make sure all required fields are filled

#### Error: "User already registered"
**Solution**: Email already exists in Supabase Auth - try different email

### 4. Test Data to Try
Try signing up with completely new data:
- Email: `test${Math.random()}@example.com`
- Student ID: Random number like `999888`
- Different name, department, etc.

### 5. Emergency Reset (if nothing works)
If you keep getting errors, you can reset the RLS policies:

```sql
-- Remove all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON public.users;

-- Add fresh policies
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);
    
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);
    
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);
```

### 6. Check Supabase Table Structure
Make sure your `users` table has these columns:
- `id` (UUID, primary key)
- `name` (TEXT)
- `student_id` (TEXT, unique)
- `email` (TEXT, unique)
- `department` (TEXT)
- `semester` (TEXT)
- `batch` (TEXT)
- `contact_number` (TEXT)
- `role` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### 7. If Still Not Working
1. Check Supabase project status (make sure it's not paused)
2. Verify internet connection
3. Check if you're using the correct Supabase URL and anon key
4. Try creating a user directly in Supabase dashboard to test table access

## Most Likely Issue
95% of the time, this error is caused by missing RLS INSERT policy. Run the SQL fix first!
