-- ============================================
-- AFRO BOOKING SYSTEM - CORRECTED SAMPLE DATA SEED
-- ============================================
-- This script matches the actual database schema

-- Clean existing sample data (keep test users)
DELETE FROM payments WHERE id NOT IN (SELECT id FROM payments WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM reviews WHERE id NOT IN (SELECT id FROM reviews WHERE "userId" IN (SELECT id FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')));
DELETE FROM user_favorites;
DELETE FROM appointment_services;
DELETE FROM appointments WHERE id NOT IN (SELECT id FROM appointments WHERE "customerId" IN (SELECT id FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')));
DELETE FROM staff WHERE "shopId" IN (SELECT id FROM shops WHERE "ownerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM services WHERE "shopId" IN (SELECT id FROM shops WHERE "ownerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM shops WHERE "ownerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM barber_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM customer_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM user_roles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM users WHERE "firebaseUid" NOT LIKE 'test_%';

-- ============================================
-- 1. CREATE SAMPLE USERS
-- ============================================

-- Customers
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES 
  (gen_random_uuid(), 'sample_customer_001', 'alice.johnson@example.com', 'Alice Johnson', '+251911234567', true, true, NOW() - INTERVAL '60 days', NOW()),
  (gen_random_uuid(), 'sample_customer_002', 'bob.smith@example.com', 'Bob Smith', '+251911234568', true, true, NOW() - INTERVAL '45 days', NOW()),
  (gen_random_uuid(), 'sample_customer_003', 'carol.white@example.com', 'Carol White', '+251911234569', true, true, NOW() - INTERVAL '30 days', NOW());

-- Providers
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES 
  (gen_random_uuid(), 'sample_provider_001', 'elite.barber@example.com', 'Michael Anderson', '+251922345678', true, true, NOW() - INTERVAL '90 days', NOW()),
  (gen_random_uuid(), 'sample_provider_002', 'luxury.salon@example.com', 'Sarah Williams', '+251922345679', true, true, NOW() - INTERVAL '85 days', NOW());

-- ============================================
-- 2. ASSIGN ROLES
-- ============================================

-- Customer roles
INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'customer', NOW()
FROM users WHERE "firebaseUid" LIKE 'sample_customer_%';

-- Provider roles
INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'customer', NOW()
FROM users WHERE "firebaseUid" LIKE 'sample_provider_%';

INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'barber', NOW()
FROM users WHERE "firebaseUid" LIKE 'sample_provider_%';

-- ============================================
-- 3. CREATE CUSTOMER PROFILES
-- ============================================

INSERT INTO customer_profiles (id, "userId", gender, "dateOfBirth", address, latitude, longitude, "notificationPreferences", "createdAt", "updatedAt")
SELECT 
  gen_random_uuid(),
  id,
  CASE 
    WHEN name LIKE '%Alice%' OR name LIKE '%Carol%' OR name LIKE '%Sarah%' THEN 'female'
    ELSE 'male'
  END,
  DATE '1990-01-01' + (random() * 10000)::int,
  'Sample Address, Addis Ababa, Ethiopia',
  9.03 + (random() * 0.02 - 0.01),
  38.74 + (random() * 0.02 - 0.01),
  '{"email": true, "sms": true, "push": true}'::json,
  NOW(),
  NOW()
FROM users WHERE "firebaseUid" LIKE 'sample_%';

-- ============================================
-- 4. CREATE BARBER PROFILES
-- ============================================

INSERT INTO barber_profiles (
  id, "userId", "businessName", "businessType", "workingHours",
  "isActive", "isVerified", rating, "totalReviews", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  u.id,
  CASE 
    WHEN u."firebaseUid" = 'sample_provider_001' THEN 'Elite Barber Shop'
    WHEN u."firebaseUid" = 'sample_provider_002' THEN 'Luxury Beauty Salon'
  END,
  CASE 
    WHEN u."firebaseUid" = 'sample_provider_001' THEN 'barber_shop'
    WHEN u."firebaseUid" = 'sample_provider_002' THEN 'salon'
  END,
  '{
    "monday": {"open": "09:00", "close": "18:00"},
    "tuesday": {"open": "09:00", "close": "18:00"},
    "wednesday": {"open": "09:00", "close": "18:00"},
    "thursday": {"open": "09:00", "close": "18:00"},
    "friday": {"open": "09:00", "close": "19:00"},
    "saturday": {"open": "08:00", "close": "17:00"},
    "sunday": {"open": false, "close": false}
  }'::json,
  true,
  true,
  4.5 + (random() * 0.5),
  (random() * 100 + 50)::int,
  NOW() - INTERVAL '90 days',
  NOW()
FROM users u WHERE u."firebaseUid" LIKE 'sample_provider_%';

-- ============================================
-- 5. CREATE SHOPS
-- ============================================

INSERT INTO shops (
  id, "ownerId", name, description, address, latitude, longitude,
  email, "isActive", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  u.id,
  bp."businessName",
  'Premium hair care and styling services in the heart of Addis Ababa',
  CASE 
    WHEN u."firebaseUid" = 'sample_provider_001' THEN 'Bole Road, Near Edna Mall, Addis Ababa, Ethiopia'
    WHEN u."firebaseUid" = 'sample_provider_002' THEN 'Kazanchis, Atlas Building, Addis Ababa, Ethiopia'
  END,
  9.03 + (random() * 0.02 - 0.01),
  38.74 + (random() * 0.02 - 0.01),
  u.email,
  true,
  NOW() - INTERVAL '90 days',
  NOW()
FROM users u
JOIN barber_profiles bp ON u.id = bp."userId"
WHERE u."firebaseUid" LIKE 'sample_provider_%';

-- ============================================
-- 6. CREATE SERVICES
-- ============================================

DO $$
DECLARE
  provider_rec RECORD;
  shop_id uuid;
  business_type text;
BEGIN
  FOR provider_rec IN 
    SELECT u.id as user_id, u."firebaseUid", bp."businessType"
    FROM users u
    JOIN barber_profiles bp ON u.id = bp."userId"
    WHERE u."firebaseUid" LIKE 'sample_provider_%'
  LOOP
    SELECT id INTO shop_id FROM shops WHERE "ownerId" = provider_rec.user_id;
    
    -- Male-focused services (barber shop)
    IF provider_rec."businessType" = 'barber_shop' THEN
      INSERT INTO services (id, "shopId", name, description, duration, price, category, "isActive", "createdAt", "updatedAt")
      VALUES 
        (gen_random_uuid(), shop_id, 'Classic Haircut', 'Traditional haircut with styling', 30, 25.00, 'haircut', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Premium Haircut', 'Haircut with wash and premium styling', 45, 40.00, 'haircut', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Beard Trim', 'Professional beard trimming and shaping', 20, 15.00, 'beard', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Hair & Beard Combo', 'Complete haircut and beard service', 50, 45.00, 'combo', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Hot Towel Shave', 'Traditional hot towel shave experience', 30, 30.00, 'shave', true, NOW(), NOW());
    END IF;
    
    -- Female-focused services (salon)
    IF provider_rec."businessType" = 'salon' THEN
      INSERT INTO services (id, "shopId", name, description, duration, price, category, "isActive", "createdAt", "updatedAt")
      VALUES 
        (gen_random_uuid(), shop_id, 'Hair Styling', 'Professional hair styling', 45, 35.00, 'styling', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Hair Coloring', 'Full hair coloring service', 120, 80.00, 'color', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Highlights', 'Hair highlights and lowlights', 90, 65.00, 'color', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Blowout', 'Professional blowout styling', 40, 30.00, 'styling', true, NOW(), NOW()),
        (gen_random_uuid(), shop_id, 'Hair Treatment', 'Deep conditioning treatment', 60, 50.00, 'treatment', true, NOW(), NOW());
    END IF;
  END LOOP;
END $$;

-- ============================================
-- 7. CREATE STAFF MEMBERS
-- ============================================

INSERT INTO staff (
  id, "shopId", firstName, lastName, email, phone, role, specialization,
  "isActive", "hireDate", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  s.id,
  'Staff',
  'Member ' || (ROW_NUMBER() OVER (PARTITION BY s.id))::text,
  'staff' || (ROW_NUMBER() OVER ())::text || '@example.com',
  '+25191' || LPAD((1000000 + random() * 9000000)::int::text, 7, '0'),
  CASE (random() * 2)::int
    WHEN 0 THEN 'senior_stylist'
    WHEN 1 THEN 'junior_stylist'
    ELSE 'barber'
  END,
  CASE (random() * 3)::int
    WHEN 0 THEN 'haircuts'
    WHEN 1 THEN 'coloring'
    WHEN 2 THEN 'styling'
    ELSE 'all_services'
  END,
  true,
  NOW() - INTERVAL '180 days',
  NOW(),
  NOW()
FROM shops s,
generate_series(1, 2) -- 2 staff per shop
;

-- ============================================
-- 8. CREATE APPOINTMENTS
-- ============================================

DO $$
DECLARE
  customer_rec RECORD;
  service_rec RECORD;
  appointment_date timestamp;
  staff_rec RECORD;
BEGIN
  -- Create past appointments (completed)
  FOR customer_rec IN 
    SELECT cp.id as customer_profile_id, u.id as user_id
    FROM customer_profiles cp
    JOIN users u ON cp."userId" = u.id
    WHERE u."firebaseUid" LIKE 'sample_customer_%'
    LIMIT 2
  LOOP
    FOR service_rec IN 
      SELECT s.id as service_id, s."shopId", s.name, s.duration, s.price, st.id as staff_id
      FROM services s
      JOIN staff st ON s."shopId" = st."shopId"
      ORDER BY random()
      LIMIT 1
    LOOP
      appointment_date := NOW() - INTERVAL '1 day' * (random() * 30 + 5)::int;
      
      INSERT INTO appointments (
        id, "userId", "customerId", "shopId", "staffId", "appointmentDate",
        "startTime", "endTime", duration, "totalPrice", status, "paymentStatus",
        notes, "createdAt", "updatedAt"
      )
      VALUES (
        gen_random_uuid(),
        customer_rec.user_id,
        customer_rec.customer_profile_id,
        service_rec."shopId",
        service_rec.staff_id,
        appointment_date,
        appointment_date,
        appointment_date + (service_rec.duration || ' minutes')::interval,
        service_rec.duration,
        service_rec.price,
        'completed',
        'paid',
        'Great service, very satisfied!',
        appointment_date - INTERVAL '2 days',
        appointment_date + INTERVAL '1 hour'
      );
      
      -- Link service to appointment
      INSERT INTO appointment_services (id, "appointmentId", "serviceId", price, duration, "createdAt", "updatedAt")
      SELECT 
        gen_random_uuid(),
        a.id,
        service_rec.service_id,
        service_rec.price,
        service_rec.duration,
        NOW(),
        NOW()
      FROM appointments a
      WHERE a."customerId" = customer_rec.customer_profile_id
      AND a."appointmentDate" = appointment_date;
    END LOOP;
  END LOOP;
  
  -- Create upcoming appointments (confirmed)
  FOR customer_rec IN 
    SELECT cp.id as customer_profile_id, u.id as user_id
    FROM customer_profiles cp
    JOIN users u ON cp."userId" = u.id
    WHERE u."firebaseUid" LIKE 'sample_customer_%'
  LOOP
    FOR service_rec IN 
      SELECT s.id as service_id, s."shopId", s.name, s.duration, s.price, st.id as staff_id
      FROM services s
      JOIN staff st ON s."shopId" = st."shopId"
      ORDER BY random()
      LIMIT 1
    LOOP
      appointment_date := NOW() + INTERVAL '1 day' * (random() * 14 + 1)::int;
      
      INSERT INTO appointments (
        id, "userId", "customerId", "shopId", "staffId", "appointmentDate",
        "startTime", "endTime", duration, "totalPrice", status, "paymentStatus",
        "createdAt", "updatedAt"
      )
      VALUES (
        gen_random_uuid(),
        customer_rec.user_id,
        customer_rec.customer_profile_id,
        service_rec."shopId",
        service_rec.staff_id,
        appointment_date,
        appointment_date,
        appointment_date + (service_rec.duration || ' minutes')::interval,
        service_rec.duration,
        service_rec.price,
        'confirmed',
        'pending',
        NOW(),
        NOW()
      );
      
      -- Link service to appointment
      INSERT INTO appointment_services (id, "appointmentId", "serviceId", price, duration, "createdAt", "updatedAt")
      SELECT 
        gen_random_uuid(),
        a.id,
        service_rec.service_id,
        service_rec.price,
        service_rec.duration,
        NOW(),
        NOW()
      FROM appointments a
      WHERE a."customerId" = customer_rec.customer_profile_id
      AND a."appointmentDate" = appointment_date;
    END LOOP;
  END LOOP;
END $$;

-- ============================================
-- 9. CREATE REVIEWS
-- ============================================

INSERT INTO reviews (
  id, "userId", "shopId", "appointmentId", rating, comment,
  "isVerified", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  cp."userId",
  a."shopId",
  a.id,
  (4 + random())::numeric(2,1),
  CASE (random() * 5)::int
    WHEN 0 THEN 'Excellent service! Very professional and friendly staff.'
    WHEN 1 THEN 'Great experience, will definitely come back again.'
    WHEN 2 THEN 'Amazing work! Exactly what I wanted.'
    WHEN 3 THEN 'Professional service, clean environment, highly recommend.'
    WHEN 4 THEN 'Best haircut I''ve had in a long time. Thank you!'
    ELSE 'Outstanding service and attention to detail.'
  END,
  true,
  a."updatedAt" + INTERVAL '2 hours',
  a."updatedAt" + INTERVAL '2 hours'
FROM appointments a
JOIN customer_profiles cp ON a."customerId" = cp.id
WHERE a.status = 'completed'
AND random() > 0.3;

-- ============================================
-- 10. CREATE FAVORITES
-- ============================================

INSERT INTO user_favorites (
  id, "userId", "shopId", "createdAt"
)
SELECT DISTINCT
  gen_random_uuid(),
  cp.id,
  s.id,
  NOW() - INTERVAL '1 day' * (random() * 30)::int
FROM customer_profiles cp
CROSS JOIN shops s
WHERE random() > 0.5
LIMIT 5;

-- ============================================
-- SUMMARY
-- ============================================

SELECT 
  'Users' as entity,
  COUNT(*) as count
FROM users
WHERE "firebaseUid" LIKE 'sample_%'
UNION ALL
SELECT 'Customer Profiles', COUNT(*) FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%')
UNION ALL
SELECT 'Barber Profiles', COUNT(*) FROM barber_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%')
UNION ALL
SELECT 'Shops', COUNT(*) FROM shops WHERE "ownerId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%')
UNION ALL
SELECT 'Services', COUNT(*) FROM services WHERE "shopId" IN (SELECT id FROM shops WHERE "ownerId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%'))
UNION ALL
SELECT 'Staff', COUNT(*) FROM staff WHERE "shopId" IN (SELECT id FROM shops WHERE "ownerId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%'))
UNION ALL
SELECT 'Appointments', COUNT(*) FROM appointments WHERE "customerId" IN (SELECT id FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%'))
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews WHERE "userId" IN (SELECT id FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%'))
UNION ALL
SELECT 'Favorites', COUNT(*) FROM user_favorites WHERE "userId" IN (SELECT id FROM customer_profiles WHERE "userId" IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'sample_%'));

