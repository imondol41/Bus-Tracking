-- Add RLS policy for admins to view their own data
CREATE POLICY "Admins can view their own data" 
ON admins FOR SELECT 
USING (auth.uid() = id);

-- Add RLS policy for admins to view their own admin requests
CREATE POLICY "Admins can view their own admin request" 
ON admin_requests FOR SELECT 
USING (auth.uid() = id);

-- Test the policies
SELECT 'Testing admin self-access' as test;
SELECT * FROM admins WHERE id = auth.uid();
