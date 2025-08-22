-- Configure Supabase for OTP-based email verification
-- This should be run in Supabase SQL Editor or via API

-- You can also configure this in your Supabase dashboard:
-- Go to Authentication > Settings > Email Templates
-- Change the "Confirm signup" template to include {{.Token}} instead of {{.ConfirmationURL}}

-- Example email template for OTP verification:
/*
Subject: Verify your email for University Bus Tracker

Hello {{.Name}},

Welcome to University Bus Tracker! Please verify your email address by entering this code in the app:

Verification Code: {{.Token}}

This code will expire in 24 hours.

If you didn't create an account, please ignore this email.

Best regards,
University Bus Tracker Team
*/
