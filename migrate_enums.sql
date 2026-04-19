-- ============================================================
-- ENUM MIGRATION: Add new professional roles and service categories
-- Run this BEFORE seed_professionals.sql if TypeORM synchronize
-- is disabled, or if you get "invalid input value for enum" errors.
-- ============================================================

-- ── StaffRole enum ──────────────────────────────────────────
DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'hair_color_specialist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'eyelash_technician';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'brow_specialist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'esthetician';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'massage_therapist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'beard_specialist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'waxing_specialist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_staff_role_enum ADD VALUE IF NOT EXISTS 'threading_specialist';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── ServiceCategory enum ────────────────────────────────────
DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'hair_treatment';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'highlights';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'balayage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'root_touch_up';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'color_correction';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'blow_dry';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'bridal_hair';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'beard_shaping';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'clean_shave';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'line_up';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'beard_coloring';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'beard_treatment';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'manicure';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'pedicure';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'gel_polish';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'acrylic_nails';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'nail_extensions';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'nail_art';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'nail_repair';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'bridal_makeup';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'party_makeup';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'natural_makeup';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'makeup_consultation';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'eyelash_extensions';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'lash_lift';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'lash_tint';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'lash_removal';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'eyebrow_shaping';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'threading';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'brow_tinting';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'brow_lamination';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'acne_treatment';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'anti_aging_facial';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'exfoliation';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'blackhead_removal';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'full_body_massage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'back_massage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'head_massage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'foot_massage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'deep_tissue_massage';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'full_body_waxing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'leg_waxing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'arm_waxing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'facial_waxing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TYPE provider_services_category_enum ADD VALUE IF NOT EXISTS 'bikini_waxing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

SELECT 'Enum migration complete' AS status;
