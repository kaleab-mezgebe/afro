-- Create test customer user
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES (
  gen_random_uuid(),
  'test_customer_001',
  'customer@test.com',
  'John Doe',
  '+251912345678',
  true,
  true,
  NOW(),
  NOW()
)
RETURNING id, "firebaseUid", email, name, phone;

-- Get the user ID for role assignment
DO $$
DECLARE
  user_id uuid;
BEGIN
  SELECT id INTO user_id FROM users WHERE "firebaseUid" = 'test_customer_001';
  
  -- Assign CUSTOMER role
  INSERT INTO user_roles (id, "userId", role, "createdAt")
  VALUES (gen_random_uuid(), user_id, 'customer', NOW());
  
  -- Create customer profile
  INSERT INTO customer_profiles (id, "userId", "notificationPreferences", "createdAt", "updatedAt")
  VALUES (
    gen_random_uuid(),
    user_id,
    '{"email": true, "sms": false, "push": true}'::jsonb,
    NOW(),
    NOW()
  );
END $$;

-- Create test provider user
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES (
  gen_random_uuid(),
  'test_provider_001',
  'provider@test.com',
  'Jane Smith',
  '+251923456789',
  true,
  true,
  NOW(),
  NOW()
)
RETURNING id, "firebaseUid", email, name, phone;

-- Assign BARBER role and create profile
DO $$
DECLARE
  user_id uuid;
BEGIN
  SELECT id INTO user_id FROM users WHERE "firebaseUid" = 'test_provider_001';
  
  -- Assign CUSTOMER role (default)
  INSERT INTO user_roles (id, "userId", role, "createdAt")
  VALUES (gen_random_uuid(), user_id, 'customer', NOW());
  
  -- Assign BARBER role
  INSERT INTO user_roles (id, "userId", role, "createdAt")
  VALUES (gen_random_uuid(), user_id, 'barber', NOW());
  
  -- Create customer profile
  INSERT INTO customer_profiles (id, "userId", "notificationPreferences", "createdAt", "updatedAt")
  VALUES (
    gen_random_uuid(),
    user_id,
    '{"email": true, "sms": false, "push": true}'::jsonb,
    NOW(),
    NOW()
  );
  
  -- Create barber profile
  INSERT INTO barber_profiles (
    id, "userId", "salonName", "genderFocus", "workingHours",
    "isActive", "isVerified", rating, "totalReviews", "createdAt", "updatedAt"
  )
  VALUES (
    gen_random_uuid(),
    user_id,
    'Elite Barber Shop',
    'unisex',
    '{
      "monday": {"open": "09:00", "close": "18:00"},
      "tuesday": {"open": "09:00", "close": "18:00"},
      "wednesday": {"open": "09:00", "close": "18:00"},
      "thursday": {"open": "09:00", "close": "18:00"},
      "friday": {"open": "09:00", "close": "18:00"},
      "saturday": {"open": "08:00", "close": "16:00"},
      "sunday": {"open": false, "close": false}
    }'::jsonb,
    true,
    false,
    0,
    0,
    NOW(),
    NOW()
  );
END $$;

-- Create test admin user
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES (
  gen_random_uuid(),
  'test_admin_001',
  'admin@test.com',
  'Admin User',
  '+251934567890',
  true,
  true,
  NOW(),
  NOW()
)
RETURNING id, "firebaseUid", email, name, phone;

-- Assign ADMIN role and create profile
DO $$
DECLARE
  user_id uuid;
BEGIN
  SELECT id INTO user_id FROM users WHERE "firebaseUid" = 'test_admin_001';
  
  -- Assign CUSTOMER role (default)
  INSERT INTO user_roles (id, "userId", role, "createdAt")
  VALUES (gen_random_uuid(), user_id, 'customer', NOW());
  
  -- Assign ADMIN role
  INSERT INTO user_roles (id, "userId", role, "createdAt")
  VALUES (gen_random_uuid(), user_id, 'admin', NOW());
  
  -- Create customer profile
  INSERT INTO customer_profiles (id, "userId", "notificationPreferences", "createdAt", "updatedAt")
  VALUES (
    gen_random_uuid(),
    user_id,
    '{"email": true, "sms": false, "push": true}'::jsonb,
    NOW(),
    NOW()
  );
  
  -- Create admin profile
  INSERT INTO admin_profiles (
    id, "userId", permissions, department, "createdAt", "updatedAt"
  )
  VALUES (
    gen_random_uuid(),
    user_id,
    '["view_analytics", "manage_users", "manage_providers"]'::jsonb,
    'Operations',
    NOW(),
    NOW()
  );
END $$;

-- Display all created users
SELECT 
  u.id,
  u."firebaseUid",
  u.email,
  u.name,
  u.phone,
  array_agg(ur.role) as roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur."userId"
WHERE u."firebaseUid" IN ('test_customer_001', 'test_provider_001', 'test_admin_001')
GROUP BY u.id, u."firebaseUid", u.email, u.name, u.phone
ORDER BY u."createdAt";
