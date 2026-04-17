-- Update barbers with proper services, images, and location data
UPDATE barbers SET 
  services = '["Hairdressing","Hair Color","Beard Trim"]'::jsonb,
  address = 'Bole, Addis Ababa'
WHERE name = 'Michael Johnson';

UPDATE barbers SET 
  services = '["Hairdressing","Shaving","Beard Trim"]'::jsonb,
  address = 'Piassa, Addis Ababa'
WHERE name = 'James Wilson';

UPDATE barbers SET 
  services = '["Hairdressing","Facial","Waxing"]'::jsonb,
  address = 'Kazanchis, Addis Ababa'
WHERE name = 'Robert Brown';

-- Add more barbers with diverse services if not already present
INSERT INTO barbers (name, email, phone, address, rating, "totalReviews", services)
VALUES
  ('Sara Haile', 'sara@salon.com', '+251911111111', 'Sarbet, Addis Ababa', 4.7, 120, '["Makeup","Nail Care","Hairdressing","Hair Color"]'::jsonb),
  ('Tigist Bekele', 'tigist@beauty.com', '+251922222222', 'CMC, Addis Ababa', 4.8, 95, '["Makeup","Facial","Waxing","Nail Care"]'::jsonb),
  ('Dawit Alemu', 'dawit@cuts.com', '+251933333333', 'Megenagna, Addis Ababa', 4.5, 78, '["Hairdressing","Shaving","Beard Trim"]'::jsonb)
ON CONFLICT (email) DO NOTHING;

SELECT name, services, address FROM barbers;
