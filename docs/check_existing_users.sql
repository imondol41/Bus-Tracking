-- Check existing users to see what emails are already taken
SELECT email, name, role, created_at FROM users ORDER BY created_at DESC;

-- If you want to delete the existing Ibrahim user to test again, use:
-- DELETE FROM users WHERE email = 'ibrahim.213061001@smuct.ac.bd';

-- Also check auth.users table (Supabase authentication table)
-- SELECT email, created_at FROM auth.users ORDER BY created_at DESC;
