-- Verify all registered users
SELECT 
  u.name,
  u.email,
  u.phone,
  array_agg(ur.role::text) as roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur."userId"
GROUP BY u.id, u.name, u.email, u.phone
ORDER BY u."createdAt";
