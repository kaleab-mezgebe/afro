-- ============================================================
-- PROFESSIONALS & SERVICES SEED DATA
-- Covers all 12 professional types with their full service lists
-- Tables: providers, provider_staff, provider_services, shops
-- ============================================================

-- Clean previous seed data from this file
DELETE FROM provider_appointment_services WHERE "serviceId" IN (
  SELECT id FROM provider_services WHERE "shopId" IN (
    SELECT id FROM shops WHERE "providerId" IN (
      SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'
    )
  )
);
DELETE FROM provider_services WHERE "shopId" IN (
  SELECT id FROM shops WHERE "providerId" IN (
    SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'
  )
);
DELETE FROM provider_staff WHERE "shopId" IN (
  SELECT id FROM shops WHERE "providerId" IN (
    SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'
  )
);
DELETE FROM shops WHERE "providerId" IN (
  SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'
);
DELETE FROM providers WHERE email LIKE 'seed_%@afrobooking.com';

-- ============================================================
-- 1. PROVIDERS (Salon Owners)
-- ============================================================

INSERT INTO providers (
  id, email, "phoneNumber", password,
  "firstName", "lastName", status, "isVerified",
  "createdAt", "updatedAt"
) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'seed_barber@afrobooking.com',    '+251911000001', '$2b$10$placeholder', 'Dawit',   'Bekele',   'approved', true, NOW(), NOW()),
  ('a1000000-0000-0000-0000-000000000002', 'seed_salon@afrobooking.com',     '+251911000002', '$2b$10$placeholder', 'Hana',    'Girma',    'approved', true, NOW(), NOW()),
  ('a1000000-0000-0000-0000-000000000003', 'seed_beauty@afrobooking.com',    '+251911000003', '$2b$10$placeholder', 'Meron',   'Tadesse',  'approved', true, NOW(), NOW()),
  ('a1000000-0000-0000-0000-000000000004', 'seed_nails@afrobooking.com',     '+251911000004', '$2b$10$placeholder', 'Tigist',  'Alemu',    'approved', true, NOW(), NOW()),
  ('a1000000-0000-0000-0000-000000000005', 'seed_makeup@afrobooking.com',    '+251911000005', '$2b$10$placeholder', 'Selam',   'Haile',    'approved', true, NOW(), NOW()),
  ('a1000000-0000-0000-0000-000000000006', 'seed_spa@afrobooking.com',       '+251911000006', '$2b$10$placeholder', 'Yonas',   'Tesfaye',  'approved', true, NOW(), NOW());

-- ============================================================
-- 2. SHOPS
-- ============================================================

INSERT INTO shops (
  id, "providerId", name, description, category,
  address, city, country, latitude, longitude,
  email, "phoneNumber", "isActive", rating, "totalReviews",
  "createdAt", "updatedAt"
) VALUES
  ('b1000000-0000-0000-0000-000000000001',
   'a1000000-0000-0000-0000-000000000001',
   'Kings Barber Shop', 'Premium men''s grooming — haircuts, fades, beard work',
   'barber_shop', 'Bole Road, Near Edna Mall', 'Addis Ababa', 'Ethiopia',
   9.0192, 38.7525, 'seed_barber@afrobooking.com', '+251911000001',
   true, 4.8, 142, NOW(), NOW()),

  ('b1000000-0000-0000-0000-000000000002',
   'a1000000-0000-0000-0000-000000000002',
   'Glow Hair Salon', 'Full-service women''s hair salon — cuts, color, styling',
   'hair_salon', 'Kazanchis, Atlas Building', 'Addis Ababa', 'Ethiopia',
   9.0227, 38.7469, 'seed_salon@afrobooking.com', '+251911000002',
   true, 4.7, 98, NOW(), NOW()),

  ('b1000000-0000-0000-0000-000000000003',
   'a1000000-0000-0000-0000-000000000003',
   'Radiance Beauty Studio', 'Makeup, lashes, brows & skin care specialists',
   'beauty_salon', 'Sarbet, CMC Road', 'Addis Ababa', 'Ethiopia',
   9.0310, 38.7612, 'seed_beauty@afrobooking.com', '+251911000003',
   true, 4.9, 211, NOW(), NOW()),

  ('b1000000-0000-0000-0000-000000000004',
   'a1000000-0000-0000-0000-000000000004',
   'Luxe Nail Studio', 'Nail art, gel, acrylics and nail care',
   'nail_studio', 'Megenagna, Friendship Building', 'Addis Ababa', 'Ethiopia',
   9.0358, 38.7891, 'seed_nails@afrobooking.com', '+251911000004',
   true, 4.6, 87, NOW(), NOW()),

  ('b1000000-0000-0000-0000-000000000005',
   'a1000000-0000-0000-0000-000000000005',
   'Glam Makeup Studio', 'Bridal, event and everyday makeup artistry',
   'makeup_studio', 'Bole Medhanialem, Sunshine Building', 'Addis Ababa', 'Ethiopia',
   9.0145, 38.7634, 'seed_makeup@afrobooking.com', '+251911000005',
   true, 4.9, 176, NOW(), NOW()),

  ('b1000000-0000-0000-0000-000000000006',
   'a1000000-0000-0000-0000-000000000006',
   'Serenity Spa & Wellness', 'Massage therapy, waxing, threading & skin treatments',
   'beauty_salon', 'Old Airport, Haile Gebre Selassie Road', 'Addis Ababa', 'Ethiopia',
   9.0089, 38.7401, 'seed_spa@afrobooking.com', '+251911000006',
   true, 4.7, 134, NOW(), NOW());


-- ============================================================
-- 3. STAFF — one per professional role per relevant shop
-- Tables: provider_staff
-- Columns: id, shopId, firstName, lastName, email, phoneNumber,
--          profileImage, role, status, bio, specialties,
--          experience, rating, totalReviews, commissionRate,
--          baseSalary, canAcceptOnlineBookings, isFeatured,
--          createdAt, updatedAt
-- ============================================================

INSERT INTO provider_staff (
  id, "shopId", "firstName", "lastName", email, "phoneNumber",
  role, status, bio, specialties, experience, rating, "totalReviews",
  "commissionRate", "baseSalary", "canAcceptOnlineBookings", "isFeatured",
  "createdAt", "updatedAt"
) VALUES

-- ── Kings Barber Shop ──────────────────────────────────────
('c1000000-0000-0000-0000-000000000001',
 'b1000000-0000-0000-0000-000000000001',
 'Abebe', 'Kebede', 'abebe@kingsbarber.com', '+251912000001',
 'barber', 'active',
 'Master barber with 8 years of experience in classic and modern cuts.',
 '["Haircut","Fade","Beard Trim","Clean Shave"]', 8, 4.9, 95,
 20.00, 8000.00, true, true, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000002',
 'b1000000-0000-0000-0000-000000000001',
 'Biruk', 'Assefa', 'biruk@kingsbarber.com', '+251912000002',
 'beard_specialist', 'active',
 'Beard specialist focused on precision shaping and beard care treatments.',
 '["Beard Styling","Beard Coloring","Beard Treatment","Precision Shaping"]', 5, 4.7, 47,
 18.00, 7000.00, true, false, NOW(), NOW()),

-- ── Glow Hair Salon ───────────────────────────────────────
('c1000000-0000-0000-0000-000000000003',
 'b1000000-0000-0000-0000-000000000002',
 'Liya', 'Tesfaye', 'liya@glowsalon.com', '+251912000003',
 'hair_stylist', 'active',
 'Senior hair stylist specializing in cuts, blowouts and bridal styling.',
 '["Haircut","Blow Dry","Hair Styling","Bridal Hairstyling"]', 7, 4.8, 88,
 22.00, 9000.00, true, true, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000004',
 'b1000000-0000-0000-0000-000000000002',
 'Rahel', 'Mulugeta', 'rahel@glowsalon.com', '+251912000004',
 'hair_color_specialist', 'active',
 'Color expert with advanced training in balayage, ombre and color correction.',
 '["Full Hair Coloring","Highlights","Balayage / Ombre","Color Correction","Toner Application"]', 6, 4.9, 72,
 25.00, 10000.00, true, true, NOW(), NOW()),

-- ── Radiance Beauty Studio ────────────────────────────────
('c1000000-0000-0000-0000-000000000005',
 'b1000000-0000-0000-0000-000000000003',
 'Feven', 'Hailu', 'feven@radiancebeauty.com', '+251912000005',
 'makeup_artist', 'active',
 'Professional makeup artist for bridal, events and editorial looks.',
 '["Full Makeup","Bridal Makeup","Natural Makeup","Party Makeup"]', 9, 4.9, 130,
 25.00, 11000.00, true, true, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000006',
 'b1000000-0000-0000-0000-000000000003',
 'Hiwot', 'Bekele', 'hiwot@radiancebeauty.com', '+251912000006',
 'eyelash_technician', 'active',
 'Certified lash artist specializing in extensions, lifts and tints.',
 '["Eyelash Extensions","Lash Lift","Lash Tint","Lash Removal"]', 4, 4.8, 61,
 20.00, 8500.00, true, false, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000007',
 'b1000000-0000-0000-0000-000000000003',
 'Mekdes', 'Girma', 'mekdes@radiancebeauty.com', '+251912000007',
 'brow_specialist', 'active',
 'Brow expert offering threading, tinting and lamination services.',
 '["Eyebrow Shaping","Threading","Brow Tinting","Brow Lamination"]', 5, 4.7, 54,
 18.00, 7500.00, true, false, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000008',
 'b1000000-0000-0000-0000-000000000003',
 'Selamawit', 'Tadesse', 'selam@radiancebeauty.com', '+251912000008',
 'esthetician', 'active',
 'Licensed esthetician specializing in facials, acne treatment and skin care.',
 '["Facial","Acne Treatment","Anti-aging Facial","Exfoliation / Peeling","Blackhead Removal"]', 6, 4.8, 79,
 20.00, 9000.00, true, true, NOW(), NOW()),

-- ── Luxe Nail Studio ──────────────────────────────────────
('c1000000-0000-0000-0000-000000000009',
 'b1000000-0000-0000-0000-000000000004',
 'Tigist', 'Worku', 'tigist@luxenails.com', '+251912000009',
 'nail_technician', 'active',
 'Nail technician with expertise in gel, acrylics and intricate nail art.',
 '["Manicure","Pedicure","Gel Polish","Acrylic Nails","Nail Art","Nail Extensions"]', 5, 4.7, 83,
 20.00, 8000.00, true, true, NOW(), NOW()),

-- ── Glam Makeup Studio ────────────────────────────────────
('c1000000-0000-0000-0000-000000000010',
 'b1000000-0000-0000-0000-000000000005',
 'Bethlehem', 'Alemu', 'beth@glamstudio.com', '+251912000010',
 'makeup_artist', 'active',
 'Award-winning makeup artist with 10+ years in bridal and fashion.',
 '["Full Makeup","Bridal Makeup","Natural Makeup","Party Makeup","Makeup Consultation"]', 10, 5.0, 176,
 30.00, 14000.00, true, true, NOW(), NOW()),

-- ── Serenity Spa & Wellness ───────────────────────────────
('c1000000-0000-0000-0000-000000000011',
 'b1000000-0000-0000-0000-000000000006',
 'Yohannes', 'Desta', 'yohannes@serenityspa.com', '+251912000011',
 'massage_therapist', 'active',
 'Certified massage therapist offering relaxation and deep tissue treatments.',
 '["Full Body Massage","Back Massage","Head Massage","Foot Massage","Deep Tissue Massage"]', 7, 4.8, 102,
 22.00, 9500.00, true, true, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000012',
 'b1000000-0000-0000-0000-000000000006',
 'Azeb', 'Solomon', 'azeb@serenityspa.com', '+251912000012',
 'waxing_specialist', 'active',
 'Waxing specialist providing smooth, long-lasting results for all body areas.',
 '["Full Body Waxing","Arm Waxing","Leg Waxing","Facial Waxing","Bikini Waxing"]', 4, 4.6, 58,
 18.00, 7500.00, true, false, NOW(), NOW()),

('c1000000-0000-0000-0000-000000000013',
 'b1000000-0000-0000-0000-000000000006',
 'Almaz', 'Kebede', 'almaz@serenityspa.com', '+251912000013',
 'threading_specialist', 'active',
 'Threading expert for precise eyebrow and facial hair shaping.',
 '["Eyebrow Threading","Upper Lip Threading","Full Face Threading"]', 6, 4.7, 74,
 15.00, 6500.00, true, false, NOW(), NOW());


-- ============================================================
-- 4. SERVICES — full catalog per shop
-- Table: provider_services
-- Columns: id, shopId, name, category, description, basePrice,
--          duration, status, isVariantBased, staffIds,
--          createdAt, updatedAt
-- ============================================================

INSERT INTO provider_services (
  id, "shopId", name, category, description,
  "basePrice", duration, status, "isVariantBased",
  "staffIds", "createdAt", "updatedAt"
) VALUES

-- ── Kings Barber Shop — Barber + Beard Specialist ─────────
('d1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001',
 'Classic Haircut', 'haircut', 'Traditional scissor cut with styling finish.',
 150.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000001"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001',
 'Fade Haircut', 'haircut', 'Skin fade or taper fade with clean finish.',
 200.00, 40, 'active', false, '["c1000000-0000-0000-0000-000000000001"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000001',
 'Kids Haircut', 'haircut', 'Gentle haircut for children under 12.',
 100.00, 25, 'active', false, '["c1000000-0000-0000-0000-000000000001"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000001',
 'Beard Trim', 'beard_trim', 'Neat beard trim and line-up.',
 100.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000001","c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000001',
 'Beard Shaping', 'beard_shaping', 'Full beard shaping and sculpting.',
 150.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000001',
 'Clean Shave', 'clean_shave', 'Hot towel clean shave with straight razor.',
 180.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000001","c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000007', 'b1000000-0000-0000-0000-000000000001',
 'Line-up / Edge-up', 'line_up', 'Crisp hairline and edge-up.',
 80.00, 15, 'active', false, '["c1000000-0000-0000-0000-000000000001"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000008', 'b1000000-0000-0000-0000-000000000001',
 'Hair Styling', 'hair_styling', 'Wash and style with premium products.',
 120.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000001"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000009', 'b1000000-0000-0000-0000-000000000001',
 'Head Massage', 'head_massage', 'Relaxing scalp and head massage.',
 100.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000001","c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000010', 'b1000000-0000-0000-0000-000000000001',
 'Beard Styling', 'beard_shaping', 'Creative beard styling and design.',
 200.00, 35, 'active', false, '["c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000011', 'b1000000-0000-0000-0000-000000000001',
 'Beard Coloring', 'beard_coloring', 'Natural or fashion beard color application.',
 250.00, 40, 'active', false, '["c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000012', 'b1000000-0000-0000-0000-000000000001',
 'Beard Treatment', 'beard_treatment', 'Deep conditioning and softening beard treatment.',
 180.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000002"]', NOW(), NOW()),

-- ── Glow Hair Salon — Hair Stylist + Color Specialist ─────
('d1000000-0000-0000-0000-000000000013', 'b1000000-0000-0000-0000-000000000002',
 'Haircut (Layered)', 'haircut', 'Layered cut tailored to face shape.',
 250.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000014', 'b1000000-0000-0000-0000-000000000002',
 'Bob Cut', 'haircut', 'Classic or modern bob cut.',
 280.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000015', 'b1000000-0000-0000-0000-000000000002',
 'Blow Dry', 'blow_dry', 'Professional blowout with round brush styling.',
 200.00, 40, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000016', 'b1000000-0000-0000-0000-000000000002',
 'Hair Styling (Updo)', 'hair_styling', 'Elegant updo for events and occasions.',
 350.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000017', 'b1000000-0000-0000-0000-000000000002',
 'Hair Wash', 'hair_styling', 'Shampoo, condition and blow dry.',
 150.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000018', 'b1000000-0000-0000-0000-000000000002',
 'Bridal Hairstyling', 'bridal_hair', 'Full bridal hair styling with trial session.',
 1200.00, 120, 'active', false, '["c1000000-0000-0000-0000-000000000003"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000019', 'b1000000-0000-0000-0000-000000000002',
 'Hair Treatment (Keratin)', 'hair_treatment', 'Keratin smoothing treatment for frizz-free hair.',
 800.00, 120, 'active', false, '["c1000000-0000-0000-0000-000000000003","c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000020', 'b1000000-0000-0000-0000-000000000002',
 'Full Hair Coloring', 'hair_coloring', 'Single process full color application.',
 600.00, 90, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000021', 'b1000000-0000-0000-0000-000000000002',
 'Root Touch-up', 'root_touch_up', 'Color refresh at the roots.',
 350.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000022', 'b1000000-0000-0000-0000-000000000002',
 'Highlights', 'highlights', 'Foil highlights for dimension and brightness.',
 700.00, 90, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000023', 'b1000000-0000-0000-0000-000000000002',
 'Balayage / Ombre', 'balayage', 'Hand-painted balayage or ombre effect.',
 900.00, 120, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000024', 'b1000000-0000-0000-0000-000000000002',
 'Color Correction', 'color_correction', 'Multi-session color correction service.',
 1500.00, 180, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000025', 'b1000000-0000-0000-0000-000000000002',
 'Toner Application', 'hair_coloring', 'Toner to neutralize brassiness.',
 250.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000004"]', NOW(), NOW()),

-- ── Radiance Beauty Studio — Makeup, Lashes, Brows, Skin ─
('d1000000-0000-0000-0000-000000000026', 'b1000000-0000-0000-0000-000000000003',
 'Full Makeup (Event)', 'makeup', 'Complete glam makeup for events.',
 500.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000005"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000027', 'b1000000-0000-0000-0000-000000000003',
 'Bridal Makeup', 'bridal_makeup', 'Full bridal makeup with trial session.',
 1500.00, 120, 'active', false, '["c1000000-0000-0000-0000-000000000005"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000028', 'b1000000-0000-0000-0000-000000000003',
 'Natural Makeup', 'natural_makeup', 'Soft, everyday natural makeup look.',
 300.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000005"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000029', 'b1000000-0000-0000-0000-000000000003',
 'Party Makeup', 'party_makeup', 'Bold and glamorous party look.',
 400.00, 50, 'active', false, '["c1000000-0000-0000-0000-000000000005"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000030', 'b1000000-0000-0000-0000-000000000003',
 'Makeup Consultation', 'makeup_consultation', 'Personalized makeup tips and product advice.',
 200.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000005"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000031', 'b1000000-0000-0000-0000-000000000003',
 'Eyelash Extensions', 'eyelash_extensions', 'Classic or volume lash extensions.',
 600.00, 90, 'active', false, '["c1000000-0000-0000-0000-000000000006"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000032', 'b1000000-0000-0000-0000-000000000003',
 'Lash Lift', 'lash_lift', 'Semi-permanent lash curl and lift.',
 400.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000006"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000033', 'b1000000-0000-0000-0000-000000000003',
 'Lash Tint', 'lash_tint', 'Lash tinting for darker, defined lashes.',
 200.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000006"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000034', 'b1000000-0000-0000-0000-000000000003',
 'Lash Removal', 'lash_removal', 'Safe removal of lash extensions.',
 150.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000006"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000035', 'b1000000-0000-0000-0000-000000000003',
 'Eyebrow Shaping', 'eyebrow_shaping', 'Precise brow shaping and clean-up.',
 150.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000007"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000036', 'b1000000-0000-0000-0000-000000000003',
 'Threading', 'threading', 'Eyebrow and facial threading.',
 100.00, 15, 'active', false, '["c1000000-0000-0000-0000-000000000007"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000037', 'b1000000-0000-0000-0000-000000000003',
 'Brow Tinting', 'brow_tinting', 'Brow tint for fuller, defined brows.',
 180.00, 25, 'active', false, '["c1000000-0000-0000-0000-000000000007"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000038', 'b1000000-0000-0000-0000-000000000003',
 'Brow Lamination', 'brow_lamination', 'Brow lamination for fluffy, brushed-up brows.',
 350.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000007"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000039', 'b1000000-0000-0000-0000-000000000003',
 'Basic Facial', 'facial', 'Deep cleansing facial with steam and extraction.',
 400.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000008"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000040', 'b1000000-0000-0000-0000-000000000003',
 'Acne Treatment', 'acne_treatment', 'Targeted acne treatment and skin calming.',
 500.00, 75, 'active', false, '["c1000000-0000-0000-0000-000000000008"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000041', 'b1000000-0000-0000-0000-000000000003',
 'Anti-aging Facial', 'anti_aging_facial', 'Firming and lifting anti-aging facial.',
 700.00, 90, 'active', false, '["c1000000-0000-0000-0000-000000000008"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000042', 'b1000000-0000-0000-0000-000000000003',
 'Exfoliation / Peeling', 'exfoliation', 'Chemical or physical exfoliation treatment.',
 450.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000008"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000043', 'b1000000-0000-0000-0000-000000000003',
 'Blackhead Removal', 'blackhead_removal', 'Deep pore cleansing and blackhead extraction.',
 350.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000008"]', NOW(), NOW()),

-- ── Luxe Nail Studio — Nail Technician ───────────────────
('d1000000-0000-0000-0000-000000000044', 'b1000000-0000-0000-0000-000000000004',
 'Manicure', 'manicure', 'Classic manicure with nail shaping and polish.',
 200.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000045', 'b1000000-0000-0000-0000-000000000004',
 'Pedicure', 'pedicure', 'Relaxing pedicure with foot soak and polish.',
 300.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000046', 'b1000000-0000-0000-0000-000000000004',
 'Gel Polish', 'gel_polish', 'Long-lasting gel polish application.',
 350.00, 45, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000047', 'b1000000-0000-0000-0000-000000000004',
 'Acrylic Nails', 'acrylic_nails', 'Full set of acrylic nail extensions.',
 600.00, 75, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000048', 'b1000000-0000-0000-0000-000000000004',
 'Nail Extensions', 'nail_extensions', 'Gel or acrylic nail extensions.',
 550.00, 70, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000049', 'b1000000-0000-0000-0000-000000000004',
 'Nail Art', 'nail_art', 'Custom nail art designs.',
 400.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000050', 'b1000000-0000-0000-0000-000000000004',
 'Nail Repair', 'nail_repair', 'Repair of broken or damaged nails.',
 150.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000051', 'b1000000-0000-0000-0000-000000000004',
 'French Tips', 'nail_care', 'Classic French manicure tips.',
 300.00, 40, 'active', false, '["c1000000-0000-0000-0000-000000000009"]', NOW(), NOW()),

-- ── Glam Makeup Studio — Makeup Artist ───────────────────
('d1000000-0000-0000-0000-000000000052', 'b1000000-0000-0000-0000-000000000005',
 'Full Makeup', 'makeup', 'Complete glam makeup for any occasion.',
 600.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000053', 'b1000000-0000-0000-0000-000000000005',
 'Bridal Makeup', 'bridal_makeup', 'Luxury bridal makeup with trial and day-of service.',
 2000.00, 150, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000054', 'b1000000-0000-0000-0000-000000000005',
 'Natural Makeup', 'natural_makeup', 'Light, everyday natural look.',
 350.00, 40, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000055', 'b1000000-0000-0000-0000-000000000005',
 'Party Makeup', 'party_makeup', 'Dramatic and bold party look.',
 500.00, 55, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000056', 'b1000000-0000-0000-0000-000000000005',
 'Makeup Consultation', 'makeup_consultation', 'One-on-one makeup tips and product guidance.',
 250.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000057', 'b1000000-0000-0000-0000-000000000005',
 'Touch-up Services', 'makeup', 'Quick makeup touch-up for events.',
 200.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000010"]', NOW(), NOW()),

-- ── Serenity Spa — Massage, Waxing, Threading ────────────
('d1000000-0000-0000-0000-000000000058', 'b1000000-0000-0000-0000-000000000006',
 'Full Body Massage', 'full_body_massage', 'Swedish full body relaxation massage.',
 700.00, 60, 'active', false, '["c1000000-0000-0000-0000-000000000011"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000059', 'b1000000-0000-0000-0000-000000000006',
 'Back Massage', 'back_massage', 'Targeted back and shoulder massage.',
 400.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000011"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000060', 'b1000000-0000-0000-0000-000000000006',
 'Head Massage', 'head_massage', 'Scalp and head relaxation massage.',
 250.00, 20, 'active', false, '["c1000000-0000-0000-0000-000000000011"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000061', 'b1000000-0000-0000-0000-000000000006',
 'Foot Massage', 'foot_massage', 'Reflexology foot massage.',
 300.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000011"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000062', 'b1000000-0000-0000-0000-000000000006',
 'Deep Tissue Massage', 'deep_tissue_massage', 'Firm deep tissue massage for muscle relief.',
 900.00, 75, 'active', false, '["c1000000-0000-0000-0000-000000000011"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000063', 'b1000000-0000-0000-0000-000000000006',
 'Full Body Waxing', 'full_body_waxing', 'Complete full body waxing session.',
 1200.00, 90, 'active', false, '["c1000000-0000-0000-0000-000000000012"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000064', 'b1000000-0000-0000-0000-000000000006',
 'Arm Waxing', 'arm_waxing', 'Full arm waxing.',
 300.00, 25, 'active', false, '["c1000000-0000-0000-0000-000000000012"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000065', 'b1000000-0000-0000-0000-000000000006',
 'Leg Waxing', 'leg_waxing', 'Full leg waxing.',
 400.00, 35, 'active', false, '["c1000000-0000-0000-0000-000000000012"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000066', 'b1000000-0000-0000-0000-000000000006',
 'Facial Waxing', 'facial_waxing', 'Upper lip, chin and brow waxing.',
 150.00, 15, 'active', false, '["c1000000-0000-0000-0000-000000000012"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000067', 'b1000000-0000-0000-0000-000000000006',
 'Bikini Waxing', 'bikini_waxing', 'Bikini line waxing.',
 350.00, 30, 'active', false, '["c1000000-0000-0000-0000-000000000012"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000068', 'b1000000-0000-0000-0000-000000000006',
 'Eyebrow Threading', 'threading', 'Precise eyebrow threading and shaping.',
 100.00, 15, 'active', false, '["c1000000-0000-0000-0000-000000000013"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000069', 'b1000000-0000-0000-0000-000000000006',
 'Upper Lip Threading', 'threading', 'Upper lip hair removal by threading.',
 60.00, 10, 'active', false, '["c1000000-0000-0000-0000-000000000013"]', NOW(), NOW()),

('d1000000-0000-0000-0000-000000000070', 'b1000000-0000-0000-0000-000000000006',
 'Full Face Threading', 'threading', 'Complete facial threading including brows, lip and chin.',
 200.00, 25, 'active', false, '["c1000000-0000-0000-0000-000000000013"]', NOW(), NOW());


-- ============================================================
-- 5. VERIFICATION SUMMARY
-- ============================================================

SELECT 'Providers'         AS entity, COUNT(*) AS count FROM providers         WHERE email LIKE 'seed_%@afrobooking.com'
UNION ALL
SELECT 'Shops',                        COUNT(*)          FROM shops              WHERE "providerId" IN (SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com')
UNION ALL
SELECT 'Staff',                        COUNT(*)          FROM provider_staff     WHERE "shopId"     IN (SELECT id FROM shops    WHERE "providerId" IN (SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'))
UNION ALL
SELECT 'Services',                     COUNT(*)          FROM provider_services  WHERE "shopId"     IN (SELECT id FROM shops    WHERE "providerId" IN (SELECT id FROM providers WHERE email LIKE 'seed_%@afrobooking.com'))
ORDER BY entity;
