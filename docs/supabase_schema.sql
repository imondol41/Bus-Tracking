-- University Bus Tracker Database Schema
-- Run these SQL commands in your Supabase SQL Editor

-- Create users table (for students)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    student_id TEXT UNIQUE,
    email TEXT NOT NULL UNIQUE,
    department TEXT,
    semester TEXT,
    batch TEXT,
    contact_number TEXT,
    role TEXT DEFAULT 'student' CHECK (role IN ('student')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create super_admins table (for super administrators)
CREATE TABLE IF NOT EXISTS public.super_admins (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create admin_requests table (for pending admin approvals)
CREATE TABLE IF NOT EXISTS public.admin_requests (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department TEXT,
    contact_number TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create admins table (for approved admins)
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department TEXT,
    contact_number TEXT,
    approved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    approved_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create buses table (for bus information and tracking)
CREATE TABLE IF NOT EXISTS public.buses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bus_number TEXT NOT NULL UNIQUE,
    route TEXT NOT NULL,
    driver TEXT NOT NULL,
    gps_latitude DECIMAL(10, 8) NOT NULL,
    gps_longitude DECIMAL(11, 8) NOT NULL,
    gps_plus_code TEXT,
    gps_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    location_name TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_student_id ON public.users(student_id);
CREATE INDEX IF NOT EXISTS idx_admin_requests_status ON public.admin_requests(status);
CREATE INDEX IF NOT EXISTS idx_buses_is_active ON public.buses(is_active);
CREATE INDEX IF NOT EXISTS idx_buses_gps_timestamp ON public.buses(gps_timestamp);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admin_requests_updated_at BEFORE UPDATE ON public.admin_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON public.admins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_super_admins_updated_at BEFORE UPDATE ON public.super_admins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_buses_updated_at BEFORE UPDATE ON public.buses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.super_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buses ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users table policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Admin requests policies
CREATE POLICY "Super admins can view all admin requests" ON public.admin_requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

CREATE POLICY "Super admins can update admin requests" ON public.admin_requests
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own admin request" ON public.admin_requests
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Admins table policies
CREATE POLICY "Super admins can view all admins" ON public.admins
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

CREATE POLICY "Super admins can manage admins" ON public.admins
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

-- Super admins table policies
CREATE POLICY "Super admins can view all super admins" ON public.super_admins
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

-- Buses table policies
CREATE POLICY "Everyone can view active buses" ON public.buses
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage buses" ON public.buses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.admins 
            WHERE id = auth.uid()
        ) OR EXISTS (
            SELECT 1 FROM public.super_admins 
            WHERE id = auth.uid()
        )
    );

-- Insert the super admin user (replace with actual user ID after authentication)
-- This should be run after the super admin signs up through the app
-- INSERT INTO public.super_admins (id, name, email) 
-- VALUES (
--     'user-uuid-from-auth-users-table',
--     'Super Admin', 
--     'shoaibhossain2302@gmail.com'
-- );

-- Create a function to handle user registration
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
    -- This function can be used to automatically handle user registration
    -- It will be called when a new user is created in auth.users
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Real-time subscriptions setup
-- Enable real-time for buses table
ALTER PUBLICATION supabase_realtime ADD TABLE public.buses;
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_requests;
