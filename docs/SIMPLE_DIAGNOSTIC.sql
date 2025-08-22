-- SIMPLE STEP-BY-STEP DIAGNOSTIC
-- Run each section one by one in Supabase SQL Editor

-- STEP 1: Check if users table exists
SELECT 'users table exists' as status
WHERE EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'users');

-- If no results, the table doesn't exist. Run this to create it:
-- CREATE TABLE public.users (
--     id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
--     name TEXT NOT NULL,
--     student_id TEXT UNIQUE,
--     email TEXT UNIQUE NOT NULL,
--     department TEXT,
--     semester TEXT,
--     batch TEXT,
--     contact_number TEXT,
--     role TEXT NOT NULL DEFAULT 'student',
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- STEP 2: Check RLS status
SELECT tablename, rowsecurity as rls_enabled 
FROM pg_tables 
WHERE tablename = 'users';

-- STEP 3: Enable RLS if not enabled
-- If rowsecurity is false, run this:
-- ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- STEP 4: Check existing policies
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'users';

-- STEP 5: Create INSERT policy if missing
-- If no INSERT policy exists, run this:
-- CREATE POLICY "users_insert_policy" ON public.users
--     FOR INSERT WITH CHECK (auth.uid() = id);

-- STEP 6: Create SELECT policy if missing  
-- CREATE POLICY "users_select_policy" ON public.users
--     FOR SELECT USING (auth.uid() = id);

-- STEP 7: Create UPDATE policy if missing
-- CREATE POLICY "users_update_policy" ON public.users
--     FOR UPDATE USING (auth.uid() = id);

-- STEP 8: Test auth.uid() function
SELECT auth.uid() as current_user_id;

-- STEP 9: Final verification - check all policies exist
SELECT 
    COUNT(CASE WHEN cmd = 'INSERT' THEN 1 END) as insert_policies,
    COUNT(CASE WHEN cmd = 'SELECT' THEN 1 END) as select_policies,
    COUNT(CASE WHEN cmd = 'UPDATE' THEN 1 END) as update_policies,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename = 'users';
