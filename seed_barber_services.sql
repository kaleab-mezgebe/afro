-- Step 1: Create barber_profiles using same IDs as barbers table
-- userId is set to the barber id itself (no real auth user needed for seed)
INSERT INTO barber_profiles (id, "userId", "salonName", description, phone, email, address, rating, "totalReviews", "isActive", "isVerified")
VALUES
  ('a7acf448-d762-438f-8a30-5113b69c6f19', 'a7acf448-d762-438f-8a30-5113b69c6f19',
   'Michael Johnson Barbershop', 'Premium cuts and grooming', '+1234567890', 'michael@barbershop.com',
   'Bole, Addis Ababa', 4.80, 156, true, true),
  ('5822444e-22bd-471f-bb41-bd69c54f664d', '5822444e-22bd-471f-bb41-bd69c54f664d',
   'James Wilson Styles', 'Classic and modern cuts', '+0987654321', 'james@styles.com',
   'Piassa, Addis Ababa', 4.60, 203, true, true),
  ('cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad',
   'Robert Brown Classic Cuts', 'Luxury grooming experience', '+1122334455', 'robert@classiccuts.com',
   'Kazanchis, Addis Ababa', 4.90, 89, true, true),
  ('4b951dac-0d58-4cbe-af48-17538d51fc99', '4b951dac-0d58-4cbe-af48-17538d51fc99',
   'Sara Haile Beauty Salon', 'Full beauty services', '+251911111111', 'sara@salon.com',
   'Sarbet, Addis Ababa', 4.70, 120, true, true),
  ('31c898e6-41e3-4fa6-94a8-4323deb6365f', '31c898e6-41e3-4fa6-94a8-4323deb6365f',
   'Tigist Bekele Beauty', 'Makeup and skincare specialist', '+251922222222', 'tigist@beauty.com',
   'CMC, Addis Ababa', 4.80, 95, true, true),
  ('2007b857-20cf-4fa5-bcaa-b5f0fca32da4', '2007b857-20cf-4fa5-bcaa-b5f0fca32da4',
   'Dawit Alemu Cuts', 'Affordable quality cuts', '+251933333333', 'dawit@cuts.com',
   'Megenagna, Addis Ababa', 4.50, 78, true, true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Insert services for each barber
-- Michael Johnson
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), 'a7acf448-d762-438f-8a30-5113b69c6f19', 'Classic Haircut', 'Precision cut with styling', 25.00, 30, true),
  (gen_random_uuid(), 'a7acf448-d762-438f-8a30-5113b69c6f19', 'Hair Color', 'Full color treatment with premium dye', 55.00, 90, true),
  (gen_random_uuid(), 'a7acf448-d762-438f-8a30-5113b69c6f19', 'Beard Trim', 'Shape and trim with hot towel finish', 15.00, 20, true),
  (gen_random_uuid(), 'a7acf448-d762-438f-8a30-5113b69c6f19', 'Cut & Beard Combo', 'Haircut plus full beard grooming', 35.00, 50, true)
ON CONFLICT DO NOTHING;

-- James Wilson
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), '5822444e-22bd-471f-bb41-bd69c54f664d', 'Haircut', 'Clean fade or scissor cut', 20.00, 30, true),
  (gen_random_uuid(), '5822444e-22bd-471f-bb41-bd69c54f664d', 'Hot Towel Shave', 'Traditional straight razor shave', 30.00, 40, true),
  (gen_random_uuid(), '5822444e-22bd-471f-bb41-bd69c54f664d', 'Beard Trim', 'Line up and shape beard', 15.00, 20, true),
  (gen_random_uuid(), '5822444e-22bd-471f-bb41-bd69c54f664d', 'Full Grooming Package', 'Haircut, shave and beard trim', 55.00, 80, true)
ON CONFLICT DO NOTHING;

-- Robert Brown
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 'Signature Haircut', 'Tailored cut with blow dry', 30.00, 45, true),
  (gen_random_uuid(), 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 'Deep Cleanse Facial', 'Exfoliation and moisturizing treatment', 50.00, 60, true),
  (gen_random_uuid(), 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 'Full Body Waxing', 'Smooth wax treatment', 40.00, 60, true),
  (gen_random_uuid(), 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 'Luxury Spa Package', 'Haircut, facial and waxing', 100.00, 150, true)
ON CONFLICT DO NOTHING;

-- Sara Haile
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), '4b951dac-0d58-4cbe-af48-17538d51fc99', 'Bridal Makeup', 'Full glam bridal look', 120.00, 120, true),
  (gen_random_uuid(), '4b951dac-0d58-4cbe-af48-17538d51fc99', 'Everyday Makeup', 'Natural day look', 45.00, 45, true),
  (gen_random_uuid(), '4b951dac-0d58-4cbe-af48-17538d51fc99', 'Gel Nail Set', 'Full gel manicure', 35.00, 60, true),
  (gen_random_uuid(), '4b951dac-0d58-4cbe-af48-17538d51fc99', 'Hair Color & Style', 'Color treatment with blowout', 75.00, 120, true)
ON CONFLICT DO NOTHING;

-- Tigist Bekele
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), '31c898e6-41e3-4fa6-94a8-4323deb6365f', 'Party Makeup', 'Bold evening look', 60.00, 60, true),
  (gen_random_uuid(), '31c898e6-41e3-4fa6-94a8-4323deb6365f', 'Anti-Aging Facial', 'Rejuvenating skin treatment', 65.00, 75, true),
  (gen_random_uuid(), '31c898e6-41e3-4fa6-94a8-4323deb6365f', 'Eyebrow Wax', 'Shape and define brows', 15.00, 15, true),
  (gen_random_uuid(), '31c898e6-41e3-4fa6-94a8-4323deb6365f', 'Nail Art', 'Custom nail design', 40.00, 60, true)
ON CONFLICT DO NOTHING;

-- Dawit Alemu
INSERT INTO barber_services (id, "barberId", name, description, price, "durationMinutes", "isActive")
VALUES
  (gen_random_uuid(), '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 'Fade Haircut', 'Low, mid or high fade', 18.00, 25, true),
  (gen_random_uuid(), '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 'Straight Razor Shave', 'Classic wet shave', 25.00, 35, true),
  (gen_random_uuid(), '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 'Beard Shape Up', 'Clean lines and edges', 12.00, 15, true),
  (gen_random_uuid(), '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 'Fade + Beard', 'Fade cut with beard shape up', 28.00, 40, true)
ON CONFLICT DO NOTHING;
