-- CREATE SUPER ADMIN ACCOUNT
-- Run this in Supabase SQL Editor

-- Step 1: First, we need to create the super admin user in auth.users
-- This is done manually through Supabase Auth

-- Step 2: Create a super admin entry in the super_admins table
-- You'll need to replace 'USER_ID_HERE' with the actual user ID after creating the auth user

-- For now, let's create a temporary super admin record that we can update later
INSERT INTO super_admins (
    id,
    email, 
    name, 
    created_at, 
    updated_at
) VALUES (
    gen_random_uuid(), -- Temporary ID, will be updated
    'superadmin@university.edu',
    'Super Administrator',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Check if the record was created
SELECT * FROM super_admins WHERE email = 'superadmin@university.edu';
