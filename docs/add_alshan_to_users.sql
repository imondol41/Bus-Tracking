-- Add ALSHAN to users table so they can login as admin
INSERT INTO users (id, name, email, department, contact_number, role, created_at)
VALUES (
    '9a416317-e801-41f9-9ca6-9d5505429e62',
    'ALSHAN',
    'alshan.213071042@smuct.ac.bd',
    'CSE',
    '01234567890',
    'admin',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    department = EXCLUDED.department,
    contact_number = EXCLUDED.contact_number;
