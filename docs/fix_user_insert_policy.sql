-- Fix for user profile creation error
-- This script adds the missing INSERT policy for the users table

-- Add INSERT policy for users table to allow new user registration
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Also ensure users can read their own profile during the signup process
-- (This policy might already exist but let's make sure)
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Check if the policies were created successfully
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'users' 
ORDER BY policyname;

-- Additional queries to check for existing duplicates
-- Check for duplicate emails in users table
SELECT email, COUNT(*) as count 
FROM public.users 
GROUP BY email 
HAVING COUNT(*) > 1;

-- Check for duplicate student IDs in users table
SELECT student_id, COUNT(*) as count 
FROM public.users 
WHERE student_id IS NOT NULL
GROUP BY student_id 
HAVING COUNT(*) > 1;

-- Check for duplicate emails across all tables
SELECT 'users' as table_name, email FROM public.users
UNION ALL
SELECT 'admin_requests' as table_name, email FROM public.admin_requests
UNION ALL
SELECT 'admins' as table_name, email FROM public.admins
UNION ALL
SELECT 'super_admins' as table_name, email FROM public.super_admins
ORDER BY email;
