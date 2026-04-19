INSERT INTO appointments (id, "userId", "barberId", "serviceType", "appointmentDate", status, "createdAt", "updatedAt")
SELECT 
  gen_random_uuid(),
  'gMTZ4HISr9gLKSvtOuhkDNEc1Hj1',
  b.id,
  'Haircut',
  NOW() + INTERVAL '2 days',
  'confirmed',
  NOW(),
  NOW()
FROM barbers b
LIMIT 1
RETURNING id, "userId", "barberId", status;
