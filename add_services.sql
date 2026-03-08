DO $$
DECLARE
  provider_id uuid;
  shop_id uuid;
BEGIN
  -- Get provider ID
  SELECT u.id INTO provider_id FROM users u WHERE u.email = 'provider@test.com';
  
  -- Check if shop exists
  SELECT id INTO shop_id FROM shops WHERE "providerId" = provider_id LIMIT 1;
  
  -- Create shop if doesn't exist
  IF shop_id IS NULL THEN
    INSERT INTO shops (
      id, "providerId", name, category, address, city, country, 
      latitude, longitude, email, "isActive", "createdAt", "updatedAt"
    )
    VALUES (
      gen_random_uuid(), 
      provider_id, 
      'Elite Barber Shop', 
      'barber_shop',
      'Bole Road, Near Edna Mall', 
      'Addis Ababa', 
      'Ethiopia', 
      9.03, 
      38.74, 
      'provider@test.com', 
      true, 
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
    id, "providerId", "shopId", name, description, 
    "durationMinutes", price, category, "isActive", 
    "createdAt", "updatedAt"
  )
  VALUES 
    (gen_random_uuid(), provider_id, shop_id, 'Classic Haircut', 'Professional haircut with styling', 30, 25.00, 'Haircut', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Premium Haircut', 'Deluxe haircut with wash and premium styling', 45, 40.00, 'Haircut', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Beard Trim', 'Professional beard trimming and shaping', 20, 15.00, 'Beard', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Hair & Beard Combo', 'Complete haircut and beard service', 45, 35.00, 'Combo', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Hot Towel Shave', 'Traditional hot towel shave experience', 30, 30.00, 'Shave', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Kids Haircut', 'Gentle haircut for children', 25, 20.00, 'Haircut', true, NOW(), NOW())
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'Services added successfully!';
END $$;

-- Verify data
SELECT 
  'Users' as entity, 
  COUNT(*) as count 
FROM users
UNION ALL 
SELECT 'Barber Profiles', COUNT(*) FROM barber_profiles
UNION ALL 
SELECT 'Shops', COUNT(*) FROM shops
UNION ALL 
SELECT 'Services', COUNT(*) FROM services
UNION ALL 
SELECT 'Appointments', COUNT(*) FROM appointments
UNION ALL 
SELECT 'Reviews', COUNT(*) FROM reviews;
