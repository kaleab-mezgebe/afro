-- ============================================
-- Simple Sample Data - Works with Current Schema
-- ============================================

-- First, let's see what we have
SELECT 'Current Data:' as status;
SELECT 'Users' as entity, COUNT(*) as count FROM users
UNION ALL SELECT 'Providers', COUNT(*) FROM providers
UNION ALL SELECT 'Barber Profiles', COUNT(*) FROM barber_profiles
UNION ALL SELECT 'Customer Profiles', COUNT(*) FROM customer_profiles
UNION ALL SELECT 'Shops', COUNT(*) FROM shops
UNION ALL SELECT 'Services', COUNT(*) FROM services;

-- Create a provider in the providers table (for Jane Smith)
DO $$
DECLARE
  provider_id uuid;
  shop_id uuid;
  barber_profile_id uuid;
BEGIN
  -- Check if provider already exists
  SELECT id INTO provider_id FROM providers WHERE email = 'provider@test.com';
  
  -- Create provider if doesn't exist
  IF provider_id IS NULL THEN
    INSERT INTO providers (
      id, email, "phoneNumber", password, "firstName", "lastName",
      status, "isVerified", "createdAt", "updatedAt"
    )
    VALUES (
      gen_random_uuid(),
      'provider@test.com',
      '+251922345678',
      '$2b$10$dummyhashedpassword', -- Dummy hash
      'Jane',
      'Smith',
      'approved',
      true,
      NOW(),
      NOW()
    )
    RETURNING id INTO provider_id;
    RAISE NOTICE 'Provider created with ID: %', provider_id;
  ELSE
    RAISE NOTICE 'Provider already exists with ID: %', provider_id;
  END IF;
  
  -- Check if shop exists
  SELECT id INTO shop_id FROM shops WHERE "providerId" = provider_id LIMIT 1;
  
  -- Create shop if doesn't exist
  IF shop_id IS NULL THEN
    INSERT INTO shops (
      id, "providerId", name, category, description, address, city, country,
      latitude, longitude, "phoneNumber", email, "isActive", rating, "totalReviews",
      "createdAt", "updatedAt"
    )
    VALUES (
      gen_random_uuid(),
      provider_id,
      'Elite Barber Shop',
      'barber_shop',
      'Premium barber services in the heart of Addis Ababa',
      'Bole Road, Near Edna Mall',
      'Addis Ababa',
      'Ethiopia',
      9.030000,
      38.740000,
      '+251922345678',
      'provider@test.com',
      true,
      0,
      0,
      NOW(),
      NOW()
    )
    RETURNING id INTO shop_id;
    RAISE NOTICE 'Shop created with ID: %', shop_id;
  ELSE
    RAISE NOTICE 'Shop already exists with ID: %', shop_id;
  END IF;
  
  -- Add services
  INSERT INTO services (
    id, "shopId", name, description, duration, "durationMinutes", price, "basePrice", category,
    "isActive", "createdAt", "updatedAt"
  )
  VALUES 
    (gen_random_uuid(), shop_id, 'Classic Haircut', 'Professional haircut with styling', 30, 30, 25.00, 25.00, 'haircut', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Premium Haircut', 'Deluxe haircut with wash and premium styling', 45, 45, 40.00, 40.00, 'haircut', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Beard Trim', 'Professional beard trimming and shaping', 20, 20, 15.00, 15.00, 'beard_trim', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Hair & Beard Combo', 'Complete haircut and beard service', 45, 45, 35.00, 35.00, 'haircut', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Hot Towel Shave', 'Traditional hot towel shave experience', 30, 30, 30.00, 30.00, 'beard_trim', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Kids Haircut', 'Gentle haircut for children', 25, 25, 20.00, 20.00, 'haircut', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Hair Coloring', 'Full hair coloring service', 90, 90, 60.00, 60.00, 'hair_coloring', true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Hair Styling', 'Professional hair styling', 40, 40, 30.00, 30.00, 'hair_styling', true, NOW(), NOW())
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'Services added successfully!';
  
  -- Add staff members
  INSERT INTO staff (
    id, "shopId", "firstName", "lastName", email, "phoneNumber", role, status,
    experience, rating, "totalReviews", "baseSalary", "canAcceptOnlineBookings",
    "isFeatured", "createdAt", "updatedAt"
  )
  VALUES 
    (gen_random_uuid(), shop_id, 'Sarah', 'Johnson', 'sarah@elite.com', '+251911111111', 'hair_stylist', 'active', 5, 4.8, 120, 45000.00, true, true, NOW(), NOW()),
    (gen_random_uuid(), shop_id, 'Mike', 'Wilson', 'mike@elite.com', '+251911111112', 'barber', 'active', 3, 4.5, 85, 38000.00, true, false, NOW(), NOW())
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'Staff added successfully!';
  
END $$;

-- Verify data
SELECT 'Final Data:' as status;
SELECT 'Users' as entity, COUNT(*) as count FROM users
UNION ALL SELECT 'Providers', COUNT(*) FROM providers
UNION ALL SELECT 'Barber Profiles', COUNT(*) FROM barber_profiles
UNION ALL SELECT 'Customer Profiles', COUNT(*) FROM customer_profiles
UNION ALL SELECT 'Shops', COUNT(*) FROM shops
UNION ALL SELECT 'Services', COUNT(*) FROM services
UNION ALL SELECT 'Staff', COUNT(*) FROM staff;

-- Show services
SELECT 'Services for Elite Barber Shop:' as info;
SELECT s.name, s.description, s.duration || ' min' as duration, '$' || s.price as price
FROM services s
JOIN shops sh ON s."shopId" = sh.id
WHERE sh.name = 'Elite Barber Shop';

