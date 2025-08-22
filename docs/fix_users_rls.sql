-- Fix RLS policies for users table to allow student signup

-- Drop existing policies that might be conflicting
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Students can view own data" ON users;
DROP POLICY IF EXISTS "Students can insert" ON users;

-- Allow anyone to insert into users table (for student signup)
CREATE POLICY "Anyone can insert into users" 
ON users FOR INSERT 
WITH CHECK (true);

-- Allow users to view their own data
CREATE POLICY "Users can view own data" 
ON users FOR SELECT 
USING (auth.uid() = id);

-- Allow users to update their own data
CREATE POLICY "Users can update own data" 
ON users FOR UPDATE 
USING (auth.uid() = id);

-- Allow super admins to view all users
CREATE POLICY "Super admins can view all users" 
ON users FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Allow super admins to manage all users
CREATE POLICY "Super admins can manage all users" 
ON users FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Make sure RLS is enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Test the policies
SELECT 'Testing users policies' as test;
