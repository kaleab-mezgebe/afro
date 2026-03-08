# Sample Data Setup Guide

## Current Status

✅ **Test Users Created** (from previous test):
- John Doe (customer@test.com) - Customer
- Jane Smith (provider@test.com) - Provider with "Elite Barber Shop"
- Admin User (admin@test.com) - Admin

✅ **Database Tables**: All 25 tables created and ready

⚠️ **Missing Data**: Services, Appointments, Reviews, Favorites

## Quick Setup via Admin Panel

The easiest way to populate the database is through the admin panel and provider app:

### Step 1: Access Admin Panel
```
URL: http://localhost:3002
Login: admin@test.com (Firebase auth)
```

### Step 2: Add More Providers
1. Navigate to "Users" page
2. Register new users via Firebase
3. Assign "barber" role to make them providers
4. System automatically creates BarberProfile

### Step 3: Provider App Setup
```
Login as: provider@test.com
```

1. **Complete Profile**:
   - Shop name: Elite Barber Shop
   - Location: Addis Ababa
   - Working hours: Mon-Sat 9AM-6PM
   - Upload profile image

2. **Add Services**:
   - Navigate to Services Management
   - Add services:
     * Haircut - $25 - 30 min
     * Beard Trim - $15 - 20 min
     * Hair & Beard - $35 - 45 min
     * Hot Towel Shave - $30 - 30 min

3. **Add Staff** (if needed):
   - Navigate to Staff Management
   - Add staff members

### Step 4: Customer App Testing
```
Login as: customer@test.com
```

1. **Browse Providers**:
   - Should see "Elite Barber Shop"
   - View services and pricing

2. **Book Appointment**:
   - Select service
   - Choose date/time
   - Confirm booking

3. **Leave Review** (after appointment):
   - Rate provider
   - Write review

## Manual SQL Seed (Alternative)

If you prefer SQL, here's a minimal working seed:

```sql
-- Get provider user ID
DO $$
DECLARE
  provider_user_id uuid;
  provider_barber_id uuid;
  shop_id uuid;
BEGIN
  -- Get Jane Smith's IDs
  SELECT u.id INTO provider_user_id 
  FROM users u 
  WHERE u.email = 'provider@test.com';
  
  SELECT id INTO provider_barber_id 
  FROM barber_profiles 
  WHERE "userId" = provider_user_id;
  
  SELECT id INTO shop_id 
  FROM shops 
  WHERE "providerId" = provider_user_id 
  LIMIT 1;
  
  -- If no shop exists, create one
  IF shop_id IS NULL THEN
    INSERT INTO shops (
      id, "providerId", name, description, address, city, country,
      latitude, longitude, email, "isActive", "createdAt", "updatedAt"
    )
    VALUES (
      gen_random_uuid(),
      provider_user_id,
      'Elite Barber Shop',
      'Premium barber services',
      'Bole Road, Addis Ababa',
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
  END IF;
  
  -- Add services
  INSERT INTO services (
    id, "providerId", "shopId", name, description, 
    "durationMinutes", price, category, "isActive", 
    "createdAt", "updatedAt"
  )
  VALUES 
    (gen_random_uuid(), provider_user_id, shop_id, 'Classic Haircut', 'Professional haircut', 30, 25.00, 'Haircut', true, NOW(), NOW()),
    (gen_random_uuid(), provider_user_id, shop_id, 'Beard Trim', 'Beard trimming and shaping', 20, 15.00, 'Beard', true, NOW(), NOW()),
    (gen_random_uuid(), provider_user_id, shop_id, 'Hair & Beard Combo', 'Complete service', 45, 35.00, 'Combo', true, NOW(), NOW()),
    (gen_random_uuid(), provider_user_id, shop_id, 'Hot Towel Shave', 'Traditional shave', 30, 30.00, 'Shave', true, NOW(), NOW())
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'Services added successfully!';
END $$;
```

## What Each App Shows

### Customer App Features Requiring Data:

1. **Home/Search** → Needs: Providers, Services
2. **Nearby Map** → Needs: Providers with locations
3. **Provider Portfolio** → Needs: Services, Reviews, Portfolio images
4. **Booking** → Needs: Services, Available time slots
5. **My Bookings** → Needs: Appointments
6. **Favorites** → Needs: User favorites
7. **Notifications** → Needs: System notifications

### Provider App Features Requiring Data:

1. **Dashboard** → Needs: Appointments, Earnings
2. **Appointments** → Needs: Customer bookings
3. **Services** → Needs: Service list
4. **Staff** → Needs: Staff members
5. **Analytics** → Needs: Appointment history, Reviews
6. **Earnings** → Needs: Completed appointments, Payments

### Admin Panel Features Requiring Data:

1. **Dashboard** → Needs: All data for analytics
2. **Users** → Shows: All registered users
3. **Providers** → Shows: All barber profiles
4. **Customers** → Shows: All customer profiles
5. **Appointments** → Shows: All bookings
6. **Analytics** → Needs: Historical data

## Recommended Testing Flow

### Phase 1: Basic Setup (5 minutes)
1. ✅ Backend running (already done)
2. ✅ Test users created (already done)
3. ⚠️ Add services via SQL or provider app
4. ⚠️ Update provider profile with details

### Phase 2: Customer Flow (10 minutes)
1. Login as customer
2. Browse providers
3. View provider portfolio
4. Book an appointment
5. View booking in "My Bookings"

### Phase 3: Provider Flow (10 minutes)
1. Login as provider
2. View dashboard
3. See incoming booking
4. Confirm/manage appointment
5. View earnings

### Phase 4: Admin Flow (5 minutes)
1. Login as admin
2. View dashboard analytics
3. Manage users
4. View all appointments
5. Verify providers

## Quick SQL to Add Services

Run this to add services for Jane Smith:

```bash
docker exec afro_postgres psql -U postgres -d afro_db -c "
DO \$\$
DECLARE
  provider_id uuid;
  shop_id uuid;
BEGIN
  SELECT u.id INTO provider_id FROM users u WHERE u.email = 'provider@test.com';
  SELECT id INTO shop_id FROM shops WHERE \"providerId\" = provider_id LIMIT 1;
  
  IF shop_id IS NULL THEN
    INSERT INTO shops (id, \"providerId\", name, address, city, country, latitude, longitude, email, \"isActive\", \"createdAt\", \"updatedAt\")
    VALUES (gen_random_uuid(), provider_id, 'Elite Barber Shop', 'Bole Road', 'Addis Ababa', 'Ethiopia', 9.03, 38.74, 'provider@test.com', true, NOW(), NOW())
    RETURNING id INTO shop_id;
  END IF;
  
  INSERT INTO services (id, \"providerId\", \"shopId\", name, description, \"durationMinutes\", price, category, \"isActive\", \"createdAt\", \"updatedAt\")
  VALUES 
    (gen_random_uuid(), provider_id, shop_id, 'Classic Haircut', 'Professional haircut with styling', 30, 25.00, 'Haircut', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Premium Haircut', 'Haircut with wash and styling', 45, 40.00, 'Haircut', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Beard Trim', 'Professional beard trimming', 20, 15.00, 'Beard', true, NOW(), NOW()),
    (gen_random_uuid(), provider_id, shop_id, 'Hair & Beard Combo', 'Complete service', 45, 35.00, 'Combo', true, NOW(), NOW())
  ON CONFLICT DO NOTHING;
END \$\$;
"
```

## Verify Data

Check what's in the database:

```bash
docker exec afro_postgres psql -U postgres -d afro_db -c "
SELECT 'Users' as entity, COUNT(*) as count FROM users
UNION ALL SELECT 'Providers', COUNT(*) FROM barber_profiles
UNION ALL SELECT 'Shops', COUNT(*) FROM shops
UNION ALL SELECT 'Services', COUNT(*) FROM services
UNION ALL SELECT 'Appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'Reviews', COUNT(*) FROM reviews;
"
```

## Expected Output

After setup, you should see:
- ✅ 3 users (customer, provider, admin)
- ✅ 1 barber profile (Jane Smith)
- ✅ 1 shop (Elite Barber Shop)
- ✅ 4+ services
- ⚠️ 0 appointments (until customer books)
- ⚠️ 0 reviews (until after appointments)

## Next Steps

1. **Add Services** (use SQL above or provider app)
2. **Test Customer App**:
   - Search for providers
   - View Elite Barber Shop
   - See services
   - Book appointment

3. **Test Provider App**:
   - View dashboard
   - Manage appointments
   - Update services

4. **Test Admin Panel**:
   - View analytics
   - Manage users
   - Monitor system

## Troubleshooting

### "No providers found"
- Check barber_profiles table has data
- Verify isActive = true
- Check shops table has location data

### "No services available"
- Run the SQL script above
- Or add via provider app
- Verify services.isActive = true

### "Can't book appointment"
- Ensure services exist
- Check provider working hours
- Verify shop is active

### "Empty dashboard"
- Need appointments for analytics
- Create test bookings
- Wait for data to populate

## Production Considerations

For production, you'll want:
1. Real user registration via Firebase
2. Provider onboarding flow
3. Service catalog management
4. Automated notifications
5. Payment processing
6. Review moderation
7. Analytics tracking

---

**Current Status**: Database ready, needs services added
**Next Action**: Run SQL script to add services, then test customer app
**Time Required**: 5 minutes for setup, 30 minutes for full testing
