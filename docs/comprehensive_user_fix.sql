-- Comprehensive Fix for User Profile Creation Error
-- Run this script in your Supabase SQL Editor to fix the signup issue

-- Step 1: Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON public.users;

-- Step 2: Create comprehensive RLS policies for users table
-- Allow users to insert their own profile during signup
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Step 3: Allow admins and super admins to view all users (for admin panel)
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.admins 
            WHERE id = auth.uid()
        ) OR EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

-- Step 4: Verify RLS is enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Step 5: Check that all policies are in place
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    cmd,
    CASE 
        WHEN qual IS NOT NULL THEN 'WITH CHECK: ' || qual
        ELSE 'No conditions'
    END as policy_condition
FROM pg_policies 
WHERE tablename = 'users' 
ORDER BY policyname;

-- Step 6: Test query to ensure the policies work
-- This should show you can query your own user record when authenticated
-- SELECT * FROM public.users WHERE id = auth.uid();

-- Additional debugging: Check if there are any constraint violations
SELECT 
    constraint_name,
    table_name,
    column_name,
    constraint_type
FROM information_schema.table_constraints tc
JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'users'
ORDER BY constraint_type, constraint_name;
