-- Check what's in barber_services for this barber
SELECT id, "barberId", name, price, "durationMinutes" 
FROM barber_services 
WHERE "barberId" = '5822444e-22bd-471f-bb41-bd69c54f664d'
LIMIT 10;

-- Also check the appointment serviceType
SELECT id, "barberId", "serviceType" FROM appointments 
WHERE "userId" = 'gMTZ4HISr9gLKSvtOuhkDNEc1Hj1';
