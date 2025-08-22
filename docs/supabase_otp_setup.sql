-- Configure Supabase for OTP-only email verification (no links)

-- Update auth settings to require email confirmation but use OTP
-- This should be done in Supabase Dashboard → Authentication → Settings

-- Email Template for OTP (should be set in Dashboard → Email Templates → Confirm signup):
/*
Subject: Your verification code for University Bus Tracker

Hello,

Welcome to University Bus Tracker! 

Your verification code is: {{ .Token }}

Please enter this 6-digit code in the app to verify your email address.

This code will expire in 10 minutes.

If you didn't create an account, please ignore this email.

Best regards,
University Bus Tracker Team
*/

-- Also make sure these settings are configured in Supabase Dashboard:
-- 1. Authentication → Settings → "Enable email confirmations" = ON
-- 2. Authentication → Settings → "Enable email change confirmations" = ON  
-- 3. Authentication → URL Configuration → "Site URL" = your app URL
-- 4. Set "Redirect URLs" if needed
