-- Super Admin Setup Script
-- Run this in your Supabase SQL Editor to create the first super admin

-- First, let's create a simple function to create super admin
CREATE OR REPLACE FUNCTION create_super_admin(
    admin_email TEXT,
    admin_name TEXT DEFAULT 'Super Admin'
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
BEGIN
    -- Generate a new UUID for the super admin
    new_user_id := gen_random_uuid();
    
    -- Insert into super_admins table
    INSERT INTO public.super_admins (id, name, email, created_at)
    VALUES (new_user_id, admin_name, admin_email, NOW());
    
    -- Return the created user ID
    RETURN new_user_id;
    
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to create super admin: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Now create the super admin
SELECT create_super_admin('shoaibhossain2302@gmail.com', 'Super Admin') as super_admin_id;

-- Verify the super admin was created
SELECT * FROM public.super_admins WHERE email = 'shoaibhossain2302@gmail.com';
