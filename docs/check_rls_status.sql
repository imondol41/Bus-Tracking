-- Check if RLS is enabled on tables
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN 'RLS is ENABLED' 
        ELSE 'RLS is DISABLED' 
    END as status
FROM pg_tables 
WHERE tablename IN ('admin_requests', 'admins', 'users', 'super_admins', 'buses')
ORDER BY tablename;

-- Also check what policies exist for these tables
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('admin_requests', 'admins')
ORDER BY tablename, policyname;
