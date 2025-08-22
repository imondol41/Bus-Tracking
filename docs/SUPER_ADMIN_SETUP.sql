-- COMPLETE SUPER ADMIN SETUP
-- Run this in Supabase SQL Editor

-- Step 1: First check if any super admins exist
SELECT email, name FROM super_admins;

-- Step 2: Create a function to add super admin after auth signup
CREATE OR REPLACE FUNCTION create_super_admin_profile(
    user_id UUID,
    user_email TEXT,
    user_name TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.super_admins (id, email, name, created_at, updated_at)
    VALUES (user_id, user_email, user_name, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        name = EXCLUDED.name,
        updated_at = NOW();
END;
$$;

-- Step 3: If you want to create a super admin from an existing auth user, 
-- replace 'YOUR_USER_ID_HERE' with an actual user ID from auth.users table
-- SELECT * FROM auth.users LIMIT 5; -- Run this first to see existing users

-- Step 4: Or create a direct super admin entry (for testing only)
-- This creates a super admin that matches your auth user
-- You'll need to create the auth user through normal signup first, then run:

-- Example: If you sign up with email 'admin@test.com' and get user ID 'abc123...'
-- Then run: SELECT create_super_admin_profile('abc123...', 'admin@test.com', 'Super Admin');

-- For immediate testing, let's create a placeholder
INSERT INTO super_admins (email, name, created_at, updated_at)
VALUES ('admin@test.com', 'Super Administrator', NOW(), NOW())
ON CONFLICT (email) DO NOTHING;
