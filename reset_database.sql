-- Reset Database Script
-- This will drop and recreate the afro_db database

-- Drop the database if it exists
DROP DATABASE IF EXISTS afro_db;

-- Create a fresh database
CREATE DATABASE afro_db;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE afro_db TO postgres;
