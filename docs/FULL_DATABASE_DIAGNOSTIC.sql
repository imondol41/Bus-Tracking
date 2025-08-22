-- COMPREHENSIVE DATABASE DIAGNOSTIC SCRIPT
-- Run this in Supabase SQL Editor to check everything

-- 1. Check if users table exists and its structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Check Row Level Security status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'users';

-- 3. Check existing RLS policies
SELECT 
    policyname, 
    cmd as command_type,
    permissive,
    qual as using_expression,
    with_check
FROM pg_policies 
WHERE tablename = 'users';

-- 4. Check table constraints (unique, foreign key, etc.)
SELECT 
    tc.constraint_name, 
    tc.constraint_type, 
    kcu.column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.table_name = 'users' 
    AND tc.table_schema = 'public';

-- 5. Test current user's permissions on users table
SELECT 
    has_table_privilege(current_user, 'public.users', 'SELECT') as can_select,
    has_table_privilege(current_user, 'public.users', 'INSERT') as can_insert,
    has_table_privilege(current_user, 'public.users', 'UPDATE') as can_update,
    has_table_privilege(current_user, 'public.users', 'DELETE') as can_delete;

-- 6. If RLS is enabled but no policies exist, create them
-- Check if we need to create policies
DO $$ 
BEGIN
    -- Check if INSERT policy exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'users' 
        AND cmd = 'INSERT'
    ) THEN
        EXECUTE '
        CREATE POLICY "Users can insert own profile during signup" ON public.users
            FOR INSERT WITH CHECK (auth.uid() = id);
        ';
        RAISE NOTICE 'Created INSERT policy for users table';
    ELSE
        RAISE NOTICE 'INSERT policy already exists for users table';
    END IF;

    -- Check if SELECT policy exists  
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'users' 
        AND cmd = 'SELECT'
    ) THEN
        EXECUTE '
        CREATE POLICY "Users can view own profile" ON public.users
            FOR SELECT USING (auth.uid() = id);
        ';
        RAISE NOTICE 'Created SELECT policy for users table';
    ELSE
        RAISE NOTICE 'SELECT policy already exists for users table';
    END IF;

    -- Check if UPDATE policy exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'users' 
        AND cmd = 'UPDATE'
    ) THEN
        EXECUTE '
        CREATE POLICY "Users can update own profile" ON public.users
            FOR UPDATE USING (auth.uid() = id);
        ';
        RAISE NOTICE 'Created UPDATE policy for users table';
    ELSE
        RAISE NOTICE 'UPDATE policy already exists for users table';
    END IF;
END $$;

-- 7. Verify the policies were created
SELECT 
    policyname, 
    cmd as command_type,
    permissive,
    qual as using_expression,
    with_check
FROM pg_policies 
WHERE tablename = 'users';

-- 8. Test inserting a sample record (this will fail but shows us the exact error)
-- Note: This will only work if you're authenticated as a user
-- INSERT INTO public.users (
--     id, name, student_id, email, department, semester, batch, contact_number, role
-- ) VALUES (
--     auth.uid(), 'Test User', 'TEST123', 'test@example.com', 'CS', '1st', '2025', '1234567890', 'student'
-- );

-- 9. Check if auth.uid() function works
SELECT auth.uid() as current_user_id;

-- 10. Final summary
SELECT 
    'Table exists: ' || CASE WHEN EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'users') THEN 'YES' ELSE 'NO' END as status
UNION ALL
SELECT 
    'RLS enabled: ' || CASE WHEN EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'users' AND rowsecurity = true) THEN 'YES' ELSE 'NO' END
UNION ALL
SELECT 
    'INSERT policy exists: ' || CASE WHEN EXISTS(SELECT 1 FROM pg_policies WHERE tablename = 'users' AND cmd = 'INSERT') THEN 'YES' ELSE 'NO' END
UNION ALL
SELECT 
    'SELECT policy exists: ' || CASE WHEN EXISTS(SELECT 1 FROM pg_policies WHERE tablename = 'users' AND cmd = 'SELECT') THEN 'YES' ELSE 'NO' END
UNION ALL
SELECT 
    'UPDATE policy exists: ' || CASE WHEN EXISTS(SELECT 1 FROM pg_policies WHERE tablename = 'users' AND cmd = 'UPDATE') THEN 'YES' ELSE 'NO' END;
