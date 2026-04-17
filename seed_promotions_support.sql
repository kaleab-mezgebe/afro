-- ============================================================
-- Seed: Promotions & Support Tickets
-- Run: psql -U postgres -d afro_db -f seed_promotions_support.sql
-- ============================================================

-- Promotions table
CREATE TABLE IF NOT EXISTS promotions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL DEFAULT 'percentage',
  discount_value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  max_discount DECIMAL(10,2),
  expires_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  usage_limit INTEGER,
  usage_count INTEGER DEFAULT 0,
  category VARCHAR(50) DEFAULT 'general',
  color VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Support tickets table
CREATE TABLE IF NOT EXISTS support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255) NOT NULL,
  subject VARCHAR(500) NOT NULL,
  message TEXT NOT NULL,
  category VARCHAR(100) DEFAULT 'General',
  status VARCHAR(20) DEFAULT 'open',
  priority VARCHAR(20) DEFAULT 'medium',
  replies JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Seed promotions
INSERT INTO promotions (code, title, description, discount_type, discount_value, min_order_amount, max_discount, expires_at, is_active, usage_limit, category, color)
VALUES
  ('WELCOME20', 'Welcome Discount', 'Get 20% off your first booking with any specialist.', 'percentage', 20, 0, 100, '2026-12-31 23:59:59', true, 1, 'new_user', '#FFB900'),
  ('SAVE50', 'Flat 50 ETB Off', 'Save 50 ETB on any booking above 200 ETB.', 'fixed', 50, 200, 50, '2026-06-30 23:59:59', true, NULL, 'general', '#4CAF50'),
  ('WEEKEND15', 'Weekend Special', '15% off all bookings on weekends.', 'percentage', 15, 100, 200, '2026-05-31 23:59:59', true, NULL, 'seasonal', '#9C27B0'),
  ('REFER10', 'Referral Bonus', 'Earn 10% off when you refer a friend who books.', 'percentage', 10, 0, 150, '2026-12-31 23:59:59', true, NULL, 'referral', '#2196F3'),
  ('SUMMER25', 'Summer Sale', '25% off all hair services this summer.', 'percentage', 25, 150, 300, '2026-08-31 23:59:59', true, NULL, 'seasonal', '#FF5722'),
  ('LOYALTY100', 'Loyalty Reward', 'Loyal customers get 100 ETB off their 5th booking.', 'fixed', 100, 300, 100, '2026-12-31 23:59:59', true, NULL, 'loyalty', '#607D8B')
ON CONFLICT (code) DO NOTHING;

-- Seed sample support tickets (using placeholder user IDs)
INSERT INTO support_tickets (user_id, subject, message, category, status, priority, replies)
VALUES
  ('sample-user-001', 'Appointment not confirmed', 'I booked an appointment but never received a confirmation email or notification.', 'Booking', 'open', 'high', '[]'),
  ('sample-user-001', 'Payment charged twice', 'My Telebirr account was charged twice for the same appointment on April 10th.', 'Payment', 'in_progress', 'urgent', '[{"from":"Support Agent","message":"We are investigating this issue and will resolve it within 24 hours. We apologize for the inconvenience.","createdAt":"2026-04-12T09:00:00Z"}]'),
  ('sample-user-002', 'Cannot update profile photo', 'The profile photo upload keeps failing with a network error.', 'Account', 'resolved', 'low', '[{"from":"Support Agent","message":"This has been fixed in the latest app update. Please update your app to version 1.0.1.","createdAt":"2026-04-07T11:00:00Z"}]')
ON CONFLICT DO NOTHING;

SELECT 'Promotions seeded: ' || COUNT(*) FROM promotions;
SELECT 'Support tickets seeded: ' || COUNT(*) FROM support_tickets;
