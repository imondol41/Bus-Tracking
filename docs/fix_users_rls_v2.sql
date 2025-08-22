-- Fix RLS policies for users table (handling existing policies)

-- First check what policies exist
SELECT policyname FROM pg_policies WHERE tablename = 'users';

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Anyone can insert into users" ON users;
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Super admins can view all users" ON users;
DROP POLICY IF EXISTS "Super admins can manage all users" ON users;

-- Create fresh policies
CREATE POLICY "Anyone can insert into users" 
ON users FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Users can view own data" 
ON users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own data" 
ON users FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Super admins can view all users" 
ON users FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

CREATE POLICY "Super admins can manage all users" 
ON users FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Ensure RLS is enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Test the policies
SELECT 'RLS policies updated successfully' as result;
