-- STEP 1: Check if RLS policies exist for users table
-- Run this query first to see what policies currently exist
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd as permission_type,
    qual as condition
FROM pg_policies 
WHERE tablename = 'users' 
ORDER BY policyname;

-- STEP 2: If you see NO policies or missing INSERT policy, run this fix:
-- (Only run this if step 1 shows missing policies)

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON public.users;

-- Create the essential INSERT policy (THIS IS THE MOST IMPORTANT ONE)
CREATE POLICY "Users can insert own profile during signup" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Recreate other essential policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- STEP 3: Verify RLS is enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- STEP 4: Test the fix with this query (should return the 3 policies)
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'users';
