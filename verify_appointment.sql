SELECT 
  a.id, 
  a."userId", 
  a.status, 
  a."appointmentDate",
  b.name as barber_name,
  b.rating
FROM appointments a 
LEFT JOIN barbers b ON b.id = a."barberId" 
WHERE a."userId" = 'gMTZ4HISr9gLKSvtOuhkDNEc1Hj1';
