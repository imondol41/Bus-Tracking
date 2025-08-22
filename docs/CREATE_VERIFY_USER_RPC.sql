-- CREATE VERIFICATION RPC FUNCTION
-- Run this in Supabase SQL Editor

CREATE OR REPLACE FUNCTION verify_user_profile(user_id UUID)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
DECLARE
    result json;
BEGIN
    SELECT to_json(u.*) INTO result
    FROM public.users u
    WHERE u.id = user_id;
    
    RETURN result;
END;
$$;
