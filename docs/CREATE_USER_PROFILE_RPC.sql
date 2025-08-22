-- CREATE RPC FUNCTION TO BYPASS RLS DURING SIGNUP
-- Run this in Supabase SQL Editor

CREATE OR REPLACE FUNCTION create_user_profile(
    id UUID,
    name TEXT,
    student_id TEXT,
    email TEXT,
    department TEXT,
    semester TEXT,
    batch TEXT,
    contact_number TEXT,
    role TEXT,
    created_at TEXT,
    updated_at TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
BEGIN
    INSERT INTO public.users (
        id, name, student_id, email, department, semester, batch, contact_number, role, created_at, updated_at
    ) VALUES (
        id, name, student_id, email, department, semester, batch, contact_number, role, created_at::timestamptz, updated_at::timestamptz
    );
END;
$$;
