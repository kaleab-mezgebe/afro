-- Add portfolioImages column if not exists
ALTER TABLE barbers ADD COLUMN IF NOT EXISTS "portfolioImages" json;

-- Update barbers with portfolio images
UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400","https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400","https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400","https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400"]'
WHERE id = 'a7acf448-d762-438f-8a30-5113b69c6f19';

UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400","https://images.unsplash.com/photo-1593702288056-7cc3b3e1e4b4?w=400","https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400","https://images.unsplash.com/photo-1534297635766-a262cdcb8ee4?w=400"]'
WHERE id = '5822444e-22bd-471f-bb41-bd69c54f664d';

UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400","https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400","https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400","https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400"]'
WHERE id = 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad';

UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?w=400","https://images.unsplash.com/photo-1519699047748-de8e457a634e?w=400","https://images.unsplash.com/photo-1526045612212-70caf35c14df?w=400","https://images.unsplash.com/photo-1512207736890-6ffed8a84e8d?w=400"]'
WHERE id = '4b951dac-0d58-4cbe-af48-17538d51fc99';

UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400","https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400","https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400","https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400"]'
WHERE id = '31c898e6-41e3-4fa6-94a8-4323deb6365f';

UPDATE barbers SET "portfolioImages" = '["https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400","https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400","https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400","https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400"]'
WHERE id = '2007b857-20cf-4fa5-bcaa-b5f0fca32da4';

-- Seed reviews using proper UUIDs for userId (fake but valid)
INSERT INTO reviews (id, "userId", "barberId", rating, comment, "isVerified") VALUES
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'a7acf448-d762-438f-8a30-5113b69c6f19', 5, 'Best haircut I have ever had! Michael is incredibly skilled.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 'a7acf448-d762-438f-8a30-5113b69c6f19', 5, 'Amazing fade and beard trim. Will definitely come back!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000003', 'a7acf448-d762-438f-8a30-5113b69c6f19', 4, 'Great service, very clean shop. Hair color came out perfect.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000004', 'a7acf448-d762-438f-8a30-5113b69c6f19', 5, 'Michael really listens to what you want. Highly recommend!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000005', 'a7acf448-d762-438f-8a30-5113b69c6f19', 4, 'Consistent quality every time. My go-to barber in Bole.', true),

  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '5822444e-22bd-471f-bb41-bd69c54f664d', 5, 'The hot towel shave was an incredible experience. So relaxing!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000002', '5822444e-22bd-471f-bb41-bd69c54f664d', 4, 'James is a true professional. Clean cuts every time.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000003', '5822444e-22bd-471f-bb41-bd69c54f664d', 5, 'Best beard trim in Piassa. Very detailed work.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000006', '5822444e-22bd-471f-bb41-bd69c54f664d', 4, 'Great atmosphere and skilled barber. Loved the full grooming package.', true),

  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 5, 'Robert is an artist. The luxury spa package was worth every penny!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000002', 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 5, 'The facial treatment left my skin glowing. Absolutely amazing.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000007', 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 5, 'Top-tier service. Robert pays attention to every detail.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000008', 'cbf3f0bb-21a8-4042-a7b8-d61fcca9dbad', 4, 'Excellent waxing service. Very professional and hygienic.', true),

  (gen_random_uuid(), '00000000-0000-0000-0000-000000000003', '4b951dac-0d58-4cbe-af48-17538d51fc99', 5, 'Sara did my bridal makeup and I looked stunning! So talented.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000004', '4b951dac-0d58-4cbe-af48-17538d51fc99', 5, 'The gel nail set lasted over 3 weeks. Perfect application!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000009', '4b951dac-0d58-4cbe-af48-17538d51fc99', 4, 'Hair color and style came out exactly as I wanted. Very happy!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000010', '4b951dac-0d58-4cbe-af48-17538d51fc99', 5, 'Best beauty salon in Sarbet. Sara is so professional and friendly.', true),

  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '31c898e6-41e3-4fa6-94a8-4323deb6365f', 5, 'Tigist is amazing at makeup. The party look she created was perfect!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000005', '31c898e6-41e3-4fa6-94a8-4323deb6365f', 4, 'The anti-aging facial made a real difference. Will come back monthly.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000006', '31c898e6-41e3-4fa6-94a8-4323deb6365f', 5, 'Nail art was creative and long-lasting. Highly recommend!', true),

  (gen_random_uuid(), '00000000-0000-0000-0000-000000000002', '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 4, 'Great fade at a fair price. Dawit is quick and precise.', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000007', '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 5, 'The straight razor shave was smooth and comfortable. Loved it!', true),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000008', '2007b857-20cf-4fa5-bcaa-b5f0fca32da4', 4, 'Fade + beard combo is great value. Clean and sharp result.', true);
