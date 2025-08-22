-- FIX USERS ROLE CHECK CONSTRAINT
-- Run this in Supabase SQL Editor

-- Step 1: Check current constraint
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'users_role_check';

-- Step 2: Check what roles are currently allowed
SELECT DISTINCT role FROM users;

-- Step 3: Drop the existing constraint
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- Step 4: Add new constraint that allows 'student' and 'admin' roles
ALTER TABLE users ADD CONSTRAINT users_role_check 
CHECK (role IN ('student', 'admin'));

-- Step 5: Verify the constraint was updated
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'users_role_check';
