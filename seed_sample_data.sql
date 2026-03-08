-- ============================================
-- AFRO BOOKING SYSTEM - SAMPLE DATA SEED
-- ============================================
-- This script creates comprehensive sample data for testing all features
-- Run this after the database schema is created

-- Clean existing data (except test users)
DELETE FROM payments WHERE id NOT IN (SELECT id FROM payments WHERE customer_id IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM reviews WHERE id NOT IN (SELECT id FROM reviews WHERE customer_id IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM user_favorites;
DELETE FROM appointment_services;
DELETE FROM appointments WHERE id NOT IN (SELECT id FROM appointments WHERE customer_id IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM barber_services WHERE "barberId" IN (SELECT id FROM barber_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM barber_schedules WHERE "barberId" IN (SELECT id FROM barber_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM staff WHERE "shopId" IN (SELECT id FROM shops WHERE "providerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%'));
DELETE FROM services WHERE "providerId" IN (SELECT id FROM users WHERE "firebaseUid" NOT LIKE 'test_%');
DELETE FROM shops WHERE "providerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM barber_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM customer_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM user_roles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
DELETE FROM users WHERE "firebaseUid" NOT LIKE 'test_%';

-- ============================================
-- 1. CREATE SAMPLE USERS (Customers & Providers)
-- ============================================

-- Customers
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES 
  (gen_random_uuid(), 'customer_001', 'alice.johnson@example.com', 'Alice Johnson', '+251911234567', true, true, NOW() - INTERVAL '60 days', NOW()),
  (gen_random_uuid(), 'customer_002', 'bob.smith@example.com', 'Bob Smith', '+251911234568', true, true, NOW() - INTERVAL '45 days', NOW()),
  (gen_random_uuid(), 'customer_003', 'carol.white@example.com', 'Carol White', '+251911234569', true, true, NOW() - INTERVAL '30 days', NOW()),
  (gen_random_uuid(), 'customer_004', 'david.brown@example.com', 'David Brown', '+251911234570', true, true, NOW() - INTERVAL '20 days', NOW()),
  (gen_random_uuid(), 'customer_005', 'emma.davis@example.com', 'Emma Davis', '+251911234571', true, true, NOW() - INTERVAL '15 days', NOW());

-- Providers
INSERT INTO users (id, "firebaseUid", email, name, phone, "isActive", "isEmailVerified", "createdAt", "updatedAt")
VALUES 
  (gen_random_uuid(), 'provider_001', 'elite.barber@example.com', 'Michael Anderson', '+251922345678', true, true, NOW() - INTERVAL '90 days', NOW()),
  (gen_random_uuid(), 'provider_002', 'luxury.salon@example.com', 'Sarah Williams', '+251922345679', true, true, NOW() - INTERVAL '85 days', NOW()),
  (gen_random_uuid(), 'provider_003', 'modern.cuts@example.com', 'James Taylor', '+251922345680', true, true, NOW() - INTERVAL '75 days', NOW()),
  (gen_random_uuid(), 'provider_004', 'beauty.lounge@example.com', 'Lisa Martinez', '+251922345681', true, true, NOW() - INTERVAL '70 days', NOW()),
  (gen_random_uuid(), 'provider_005', 'classic.barber@example.com', 'Robert Garcia', '+251922345682', true, true, NOW() - INTERVAL '65 days', NOW());

-- ============================================
-- 2. ASSIGN ROLES
-- ============================================

-- Customer roles
INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'customer', NOW()
FROM users WHERE "firebaseUid" LIKE 'customer_%';

-- Provider roles (customer + barber)
INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'customer', NOW()
FROM users WHERE "firebaseUid" LIKE 'provider_%';

INSERT INTO user_roles (id, "userId", role, "createdAt")
SELECT gen_random_uuid(), id, 'barber', NOW()
FROM users WHERE "firebaseUid" LIKE 'provider_%';

-- ============================================
-- 3. CREATE CUSTOMER PROFILES
-- ============================================

INSERT INTO customer_profiles (id, "userId", gender, "dateOfBirth", address, city, country, "notificationPreferences", "createdAt", "updatedAt")
SELECT 
  gen_random_uuid(),
  id,
  CASE 
    WHEN name LIKE '%Alice%' OR name LIKE '%Carol%' OR name LIKE '%Emma%' OR name LIKE '%Sarah%' OR name LIKE '%Lisa%' THEN 'female'
    ELSE 'male'
  END,
  DATE '1990-01-01' + (random() * 10000)::int,
  'Sample Address ' || SUBSTRING(name FROM 1 FOR 1),
  'Addis Ababa',
  'Ethiopia',
  '{"email": true, "sms": true, "push": true}'::jsonb,
  NOW(),
  NOW()
FROM users WHERE "firebaseUid" LIKE 'customer_%' OR "firebaseUid" LIKE 'provider_%';

-- ============================================
-- 4. CREATE BARBER PROFILES
-- ============================================

INSERT INTO barber_profiles (
  id, "userId", "salonName", "genderFocus", "workingHours",
  "isActive", "isVerified", rating, "totalReviews", bio, "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  u.id,
  CASE 
    WHEN u."firebaseUid" = 'provider_001' THEN 'Elite Barber Shop'
    WHEN u."firebaseUid" = 'provider_002' THEN 'Luxury Beauty Salon'
    WHEN u."firebaseUid" = 'provider_003' THEN 'Modern Cuts Studio'
    WHEN u."firebaseUid" = 'provider_004' THEN 'Beauty Lounge & Spa'
    WHEN u."firebaseUid" = 'provider_005' THEN 'Classic Barber Co.'
  END,
  CASE 
    WHEN u."firebaseUid" IN ('provider_001', 'provider_003', 'provider_005') THEN 'male'
    WHEN u."firebaseUid" IN ('provider_002', 'provider_004') THEN 'female'
  END,
  '{
    "monday": {"open": "09:00", "close": "18:00"},
    "tuesday": {"open": "09:00", "close": "18:00"},
    "wednesday": {"open": "09:00", "close": "18:00"},
    "thursday": {"open": "09:00", "close": "18:00"},
    "friday": {"open": "09:00", "close": "19:00"},
    "saturday": {"open": "08:00", "close": "17:00"},
    "sunday": {"open": false, "close": false}
  }'::jsonb,
  true,
  CASE WHEN u."firebaseUid" IN ('provider_001', 'provider_002', 'provider_003') THEN true ELSE false END,
  4.5 + (random() * 0.5),
  (random() * 100 + 50)::int,
  'Professional hair care services with years of experience. We pride ourselves on quality and customer satisfaction.',
  NOW() - INTERVAL '90 days',
  NOW()
FROM users u WHERE u."firebaseUid" LIKE 'provider_%';

-- ============================================
-- 5. CREATE SHOPS
-- ============================================

INSERT INTO shops (
  id, "providerId", name, description, address, city, country,
  latitude, longitude, phone, email, "isActive", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  u.id,
  bp."salonName",
  'Premium hair care and styling services in the heart of Addis Ababa',
  CASE 
    WHEN u."firebaseUid" = 'provider_001' THEN 'Bole Road, Near Edna Mall'
    WHEN u."firebaseUid" = 'provider_002' THEN 'Kazanchis, Atlas Building'
    WHEN u."firebaseUid" = 'provider_003' THEN 'Megenagna, CMC Area'
    WHEN u."firebaseUid" = 'provider_004' THEN 'Bole, Millennium Hall Area'
    WHEN u."firebaseUid" = 'provider_005' THEN 'Piassa, Churchill Avenue'
  END,
  'Addis Ababa',
  'Ethiopia',
  9.03 + (random() * 0.02 - 0.01),
  38.74 + (random() * 0.02 - 0.01),
  u.phone,
  u.email,
  true,
  NOW() - INTERVAL '90 days',
  NOW()
FROM users u
JOIN barber_profiles bp ON u.id = bp."userId"
WHERE u."firebaseUid" LIKE 'provider_%';

-- ============================================
-- 6. CREATE SERVICES
-- ============================================

DO $$
DECLARE
  provider_rec RECORD;
  shop_id uuid;
BEGIN
  FOR provider_rec IN SELECT u.id as user_id, u."firebaseUid", bp."genderFocus"
    FROM users u
    JOIN barber_profiles bp ON u.id = bp."userId"
    WHERE u."firebaseUid" LIKE 'provider_%'
  LOOP
    SELECT id INTO shop_id FROM shops WHERE "providerId" = provider_rec.user_id;
    
    -- Male-focused services
    IF provider_rec."genderFocus" IN ('male', 'unisex') THEN
      INSERT INTO services (id, "providerId", "shopId", name, description, "durationMinutes", price, category, "isActive", "createdAt", "updatedAt")
      VALUES 
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Classic Haircut', 'Traditional haircut with styling', 30, 25.00, 'Haircut', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Premium Haircut', 'Haircut with wash and premium styling', 45, 40.00, 'Haircut', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Beard Trim', 'Professional beard trimming and shaping', 20, 15.00, 'Beard', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Hair & Beard Combo', 'Complete haircut and beard service', 50, 45.00, 'Combo', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Hot Towel Shave', 'Traditional hot towel shave experience', 30, 30.00, 'Shave', true, NOW(), NOW());
    END IF;
    
    -- Female-focused services
    IF provider_rec."genderFocus" IN ('female', 'unisex') THEN
      INSERT INTO services (id, "providerId", "shopId", name, description, "durationMinutes", price, category, "isActive", "createdAt", "updatedAt")
      VALUES 
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Hair Styling', 'Professional hair styling', 45, 35.00, 'Styling', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Hair Coloring', 'Full hair coloring service', 120, 80.00, 'Color', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Highlights', 'Hair highlights and lowlights', 90, 65.00, 'Color', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Blowout', 'Professional blowout styling', 40, 30.00, 'Styling', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Hair Treatment', 'Deep conditioning treatment', 60, 50.00, 'Treatment', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Manicure', 'Professional manicure service', 45, 25.00, 'Nails', true, NOW(), NOW()),
        (gen_random_uuid(), provider_rec.user_id, shop_id, 'Pedicure', 'Professional pedicure service', 60, 35.00, 'Nails', true, NOW(), NOW());
    END IF;
  END LOOP;
END $$;

-- ============================================
-- 7. CREATE STAFF MEMBERS
-- ============================================

INSERT INTO staff (
  id, "shopId", name, role, specialization, phone, email,
  "isActive", "hireDate", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  s.id,
  'Staff Member ' || (ROW_NUMBER() OVER (PARTITION BY s.id))::text,
  CASE (random() * 2)::int
    WHEN 0 THEN 'Senior Stylist'
    WHEN 1 THEN 'Junior Stylist'
    ELSE 'Barber'
  END,
  CASE (random() * 3)::int
    WHEN 0 THEN 'Haircuts'
    WHEN 1 THEN 'Coloring'
    WHEN 2 THEN 'Styling'
    ELSE 'All Services'
  END,
  '+25191' || LPAD((1000000 + random() * 9000000)::int::text, 7, '0'),
  'staff' || (ROW_NUMBER() OVER ())::text || '@example.com',
  true,
  NOW() - INTERVAL '180 days',
  NOW(),
  NOW()
FROM shops s,
generate_series(1, 3) -- 3 staff per shop
;

-- ============================================
-- 8. CREATE APPOINTMENTS
-- ============================================

DO $$
DECLARE
  customer_rec RECORD;
  provider_rec RECORD;
  service_rec RECORD;
  appointment_date timestamp;
  appointment_status text;
BEGIN
  -- Create past appointments (completed)
  FOR customer_rec IN SELECT id FROM users WHERE "firebaseUid" LIKE 'customer_%' LIMIT 3
  LOOP
    FOR provider_rec IN SELECT u.id as provider_id, s.id as service_id, s.name, s."durationMinutes", s.price
      FROM users u
      JOIN services s ON u.id = s."providerId"
      WHERE u."firebaseUid" LIKE 'provider_%'
      ORDER BY random()
      LIMIT 2
    LOOP
      appointment_date := NOW() - INTERVAL '1 day' * (random() * 30 + 5)::int;
      
      INSERT INTO appointments (
        id, customer_id, provider_id, service_id, "appointmentDate",
        "durationMinutes", price, status, "paymentStatus", notes,
        "createdAt", "updatedAt"
      )
      VALUES (
        gen_random_uuid(),
        customer_rec.id,
        provider_rec.provider_id,
        provider_rec.service_id,
        appointment_date,
        provider_rec."durationMinutes",
        provider_rec.price,
        'completed',
        'paid',
        'Great service, very satisfied!',
        appointment_date - INTERVAL '2 days',
        appointment_date + INTERVAL '1 hour'
      );
    END LOOP;
  END LOOP;
  
  -- Create upcoming appointments (confirmed)
  FOR customer_rec IN SELECT id FROM users WHERE "firebaseUid" LIKE 'customer_%'
  LOOP
    FOR provider_rec IN SELECT u.id as provider_id, s.id as service_id, s.name, s."durationMinutes", s.price
      FROM users u
      JOIN services s ON u.id = s."providerId"
      WHERE u."firebaseUid" LIKE 'provider_%'
      ORDER BY random()
      LIMIT 1
    LOOP
      appointment_date := NOW() + INTERVAL '1 day' * (random() * 14 + 1)::int;
      
      INSERT INTO appointments (
        id, customer_id, provider_id, service_id, "appointmentDate",
        "durationMinutes", price, status, "paymentStatus", notes,
        "createdAt", "updatedAt"
      )
      VALUES (
        gen_random_uuid(),
        customer_rec.id,
        provider_rec.provider_id,
        provider_rec.service_id,
        appointment_date,
        provider_rec."durationMinutes",
        provider_rec.price,
        'confirmed',
        'pending',
        NULL,
        NOW(),
        NOW()
      );
    END LOOP;
  END LOOP;
END $$;

-- ============================================
-- 9. CREATE REVIEWS
-- ============================================

INSERT INTO reviews (
  id, customer_id, provider_id, appointment_id, rating, comment,
  "isVerified", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  a.customer_id,
  a.provider_id,
  a.id,
  (4 + random())::numeric(2,1), -- Rating between 4.0 and 5.0
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
WHERE a.status = 'completed'
AND random() > 0.3; -- 70% of completed appointments have reviews

-- ============================================
-- 10. CREATE FAVORITES
-- ============================================

INSERT INTO user_favorites (
  id, customer_id, provider_id, "createdAt"
)
SELECT DISTINCT
  gen_random_uuid(),
  c.id,
  p.id,
  NOW() - INTERVAL '1 day' * (random() * 30)::int
FROM users c
CROSS JOIN users p
WHERE c."firebaseUid" LIKE 'customer_%'
AND p."firebaseUid" LIKE 'provider_%'
AND random() > 0.5 -- 50% chance of favorite
LIMIT 15;

-- ============================================
-- 11. CREATE PAYMENTS
-- ============================================

INSERT INTO payments (
  id, customer_id, provider_id, appointment_id, amount, currency,
  "paymentMethod", "paymentStatus", "transactionId", "platformFee",
  "providerEarnings", "createdAt", "updatedAt"
)
SELECT 
  gen_random_uuid(),
  a.customer_id,
  a.provider_id,
  a.id,
  a.price,
  'USD',
  CASE (random() * 4)::int
    WHEN 0 THEN 'stripe'
    WHEN 1 THEN 'paypal'
    WHEN 2 THEN 'chapa'
    ELSE 'cash'
  END,
  CASE 
    WHEN a."paymentStatus" = 'paid' THEN 'completed'
    ELSE 'pending'
  END,
  'TXN_' || UPPER(SUBSTRING(MD5(random()::text) FROM 1 FOR 12)),
  a.price * 0.15, -- 15% platform fee
  a.price * 0.85, -- 85% to provider
  a."appointmentDate" - INTERVAL '1 day',
  a."appointmentDate" - INTERVAL '1 day'
FROM appointments a
WHERE a."paymentStatus" = 'paid';

-- ============================================
-- SUMMARY QUERY
-- ============================================

SELECT 
  'Users' as entity,
  COUNT(*) as count
FROM users
WHERE "firebaseUid" NOT LIKE 'test_%'
UNION ALL
SELECT 'Customer Profiles', COUNT(*) FROM customer_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Barber Profiles', COUNT(*) FROM barber_profiles WHERE "userId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Shops', COUNT(*) FROM shops WHERE "providerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Services', COUNT(*) FROM services WHERE "providerId" NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Staff', COUNT(*) FROM staff
UNION ALL
SELECT 'Appointments', COUNT(*) FROM appointments WHERE customer_id NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews WHERE customer_id NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Favorites', COUNT(*) FROM user_favorites WHERE customer_id NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%')
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments WHERE customer_id NOT IN (SELECT id FROM users WHERE "firebaseUid" LIKE 'test_%');
