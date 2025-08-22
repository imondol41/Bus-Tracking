-- First, let's drop existing policies to start fresh
DROP POLICY IF EXISTS "Super admins can update admin requests" ON admin_requests;
DROP POLICY IF EXISTS "Super admins can view all admin requests" ON admin_requests;
DROP POLICY IF EXISTS "Users can insert their own admin request" ON admin_requests;
DROP POLICY IF EXISTS "Users can view own admin request" ON admin_requests;
DROP POLICY IF EXISTS "Anyone can insert admin requests" ON admin_requests;
DROP POLICY IF EXISTS "Users can view admin requests" ON admin_requests;

-- Admin requests table policies
-- Allow anyone to insert admin requests (for signup)
CREATE POLICY "Anyone can insert admin requests" 
ON admin_requests FOR INSERT 
WITH CHECK (true);

-- Allow users to view their own admin requests
CREATE POLICY "Users can view own admin requests" 
ON admin_requests FOR SELECT 
USING (auth.uid() = id);

-- Allow super admins to view all admin requests
CREATE POLICY "Super admins can view all admin requests" 
ON admin_requests FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Allow super admins to update admin requests (approve/reject)
CREATE POLICY "Super admins can update admin requests" 
ON admin_requests FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Allow super admins to delete admin requests if needed
CREATE POLICY "Super admins can delete admin requests" 
ON admin_requests FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Admins table policies
-- Drop existing policies for admins table
DROP POLICY IF EXISTS "Super admins can view all admins" ON admins;
DROP POLICY IF EXISTS "Super admins can insert admins" ON admins;
DROP POLICY IF EXISTS "Super admins can delete admins" ON admins;

-- Allow super admins to view all admins
CREATE POLICY "Super admins can view all admins" 
ON admins FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Allow super admins to insert new admins
CREATE POLICY "Super admins can insert admins" 
ON admins FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Allow super admins to delete admins
CREATE POLICY "Super admins can delete admins" 
ON admins FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM super_admins 
    WHERE super_admins.id = auth.uid()
  )
);

-- Make sure RLS is enabled on both tables
ALTER TABLE admin_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Test query to verify the policies work
SELECT 'Testing admin_requests policies' as test;
SELECT * FROM admin_requests LIMIT 1;

SELECT 'Testing admins policies' as test;
SELECT * FROM admins LIMIT 1;
