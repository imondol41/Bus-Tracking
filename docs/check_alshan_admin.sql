-- Temporarily disable RLS to check if ALSHAN exists in admins table
ALTER TABLE admins DISABLE ROW LEVEL SECURITY;

-- Check if ALSHAN exists
SELECT * FROM admins WHERE id = '9a416317-e801-41f9-9ca6-9d5505429e62';

-- Check all admins
SELECT * FROM admins;

-- Re-enable RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
