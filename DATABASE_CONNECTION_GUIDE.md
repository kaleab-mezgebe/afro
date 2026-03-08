# Database Connection Guide - PostgreSQL Setup

## Overview

This guide will walk you through setting up and connecting to the PostgreSQL database for the AFRO Barber Shop system.

---

## Prerequisites

Before connecting to the database, ensure you have:

1. ✅ PostgreSQL installed (version 12 or higher)
2. ✅ Node.js installed (for backend)
3. ✅ Backend code ready
4. ✅ Environment variables configured

---

## Step 1: Install PostgreSQL

### Windows

1. **Download PostgreSQL**
   - Visit: https://www.postgresql.org/download/windows/
   - Download the installer (recommended: PostgreSQL 15 or 16)

2. **Run the Installer**
   ```
   - Click through the installation wizard
   - Set a password for the postgres user (REMEMBER THIS!)
   - Default port: 5432 (keep this)
   - Install pgAdmin 4 (recommended for GUI management)
   ```

3. **Verify Installation**
   ```bash
   psql --version
   ```

### macOS

1. **Using Homebrew**
   ```bash
   brew install postgresql@15
   brew services start postgresql@15
   ```

2. **Or Download from Website**
   - Visit: https://www.postgresql.org/download/macosx/
   - Download and install Postgres.app

3. **Verify Installation**
   ```bash
   psql --version
   ```

### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify installation
psql --version
```

---

## Step 2: Create Database

### Option A: Using Command Line

1. **Access PostgreSQL**
   ```bash
   # Windows (Command Prompt as Administrator)
   psql -U postgres

   # macOS/Linux
   sudo -u postgres psql
   ```

2. **Create Database**
   ```sql
   -- Create the database
   CREATE DATABASE afro_db;

   -- Create a user (optional, for security)
   CREATE USER afro_user WITH ENCRYPTED PASSWORD 'your_secure_password';

   -- Grant privileges
   GRANT ALL PRIVILEGES ON DATABASE afro_db TO afro_user;

   -- Connect to the database
   \c afro_db

   -- Grant schema privileges
   GRANT ALL ON SCHEMA public TO afro_user;

   -- Exit
   \q
   ```

### Option B: Using pgAdmin 4 (GUI)

1. **Open pgAdmin 4**
   - Launch pgAdmin from Start Menu (Windows) or Applications (macOS)

2. **Connect to Server**
   - Right-click "Servers" → "Create" → "Server"
   - Name: Local PostgreSQL
   - Host: localhost
   - Port: 5432
   - Username: postgres
   - Password: (your postgres password)

3. **Create Database**
   - Right-click "Databases" → "Create" → "Database"
   - Database name: `afro_db`
   - Owner: postgres (or afro_user if created)
   - Click "Save"

---

## Step 3: Configure Backend Environment

1. **Navigate to Backend Directory**
   ```bash
   cd backend
   ```

2. **Create .env File**
   ```bash
   # Copy the example file
   cp .env.example .env

   # Or create manually
   # Windows: type nul > .env
   # macOS/Linux: touch .env
   ```

3. **Edit .env File**
   ```env
   # Application
   NODE_ENV=development
   PORT=3001

   # Database Configuration (PostgreSQL)
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=your_postgres_password
   DB_NAME=afro_db

   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_CLIENT_EMAIL=your-client-email@your-project.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Private-Key-Here\n-----END PRIVATE KEY-----\n"
   FIREBASE_DATABASE_URL=https://your-project.firebaseio.com

   # JWT Configuration
   JWT_SECRET=your-jwt-secret-key-here-make-it-long-and-random
   JWT_EXPIRATION=7d

   # Rate Limiting
   THROTTLE_TTL=60000
   THROTTLE_LIMIT=100

   # Cache Configuration
   CACHE_TTL=300
   CACHE_MAX=100

   # CORS Origins
   CORS_ORIGINS=http://localhost:3000,http://localhost:3002
   ```

4. **Important Notes**
   - Replace `your_postgres_password` with your actual PostgreSQL password
   - Replace Firebase credentials with your actual Firebase project credentials
   - Generate a strong JWT secret (use: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`)

---

## Step 4: Install Backend Dependencies

```bash
cd backend
npm install
```

This will install all required packages including:
- `pg` - PostgreSQL driver
- `typeorm` - ORM for database operations
- `@nestjs/typeorm` - NestJS TypeORM integration

---

## Step 5: Run Database Migrations

### Option A: Auto-Sync (Development Only)

The backend is configured to automatically sync the database schema in development mode:

```bash
npm run start:dev
```

This will:
- Create all tables automatically
- Set up relationships
- Create indexes

**⚠️ Warning**: Auto-sync is only for development. Never use in production!

### Option B: Manual Migrations (Recommended for Production)

1. **Generate Migration**
   ```bash
   npm run migration:generate -- src/migrations/InitialSchema
   ```

2. **Run Migrations**
   ```bash
   npm run migration:run
   ```

3. **Revert Migration (if needed)**
   ```bash
   npm run migration:revert
   ```

---

## Step 6: Verify Database Connection

### Method 1: Start the Backend

```bash
cd backend
npm run start:dev
```

**Expected Output:**
```
🚀 Server running on http://localhost:3001
📚 API Docs: http://localhost:3001/api/docs
❤️  Health Check: http://localhost:3001/health
🔥 Environment: development
💾 Database: PostgreSQL on localhost:5432
```

### Method 2: Check Health Endpoint

Open your browser or use curl:

```bash
curl http://localhost:3001/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "info": {
    "database": {
      "status": "up"
    },
    "memory_heap": {
      "status": "up"
    },
    "memory_rss": {
      "status": "up"
    },
    "storage": {
      "status": "up"
    }
  }
}
```

### Method 3: Check Database Directly

```bash
# Connect to database
psql -U postgres -d afro_db

# List all tables
\dt

# Expected tables:
# - users
# - user_roles
# - customer_profiles
# - barber_profiles
# - admin_profiles
# - appointments
# - services
# - payments
# - reviews
# - favorites
# - query_result_cache

# Exit
\q
```

---

## Step 7: Verify API Documentation

1. **Open Swagger UI**
   - Navigate to: http://localhost:3001/api/docs

2. **Test an Endpoint**
   - Click on "Health" → "GET /health"
   - Click "Try it out"
   - Click "Execute"
   - Should return status 200 with health information

---

## Database Schema Overview

### Core Tables

#### users
- id (UUID, Primary Key)
- firebaseUid (String, Unique)
- email (String, Unique)
- name (String)
- phone (String)
- isEmailVerified (Boolean)
- createdAt (Timestamp)
- updatedAt (Timestamp)

#### user_roles
- id (UUID, Primary Key)
- userId (UUID, Foreign Key → users)
- role (Enum: CUSTOMER, BARBER, ADMIN)
- createdAt (Timestamp)

#### customer_profiles
- id (UUID, Primary Key)
- userId (UUID, Foreign Key → users)
- preferences (JSON)
- notificationPreferences (JSON)
- createdAt (Timestamp)
- updatedAt (Timestamp)

#### barber_profiles
- id (UUID, Primary Key)
- userId (UUID, Foreign Key → users)
- salonName (String)
- genderFocus (Enum)
- workingHours (JSON)
- location (JSON)
- createdAt (Timestamp)
- updatedAt (Timestamp)

#### appointments
- id (UUID, Primary Key)
- userId (UUID, Foreign Key → users)
- barberId (UUID, Foreign Key → barber_profiles)
- serviceType (String)
- appointmentDate (DateTime)
- status (Enum: pending, confirmed, cancelled, completed)
- notes (Text)
- createdAt (Timestamp)
- updatedAt (Timestamp)

#### payments
- id (UUID, Primary Key)
- appointmentId (UUID, Foreign Key → appointments)
- customerId (UUID, Foreign Key → users)
- providerId (UUID, Foreign Key → users)
- amount (Decimal)
- currency (String)
- paymentMethod (Enum)
- status (Enum)
- platformFee (Decimal)
- providerAmount (Decimal)
- createdAt (Timestamp)

---

## Common Connection Issues & Solutions

### Issue 1: "Connection Refused"

**Symptoms:**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solutions:**
1. Check if PostgreSQL is running:
   ```bash
   # Windows
   services.msc (look for postgresql service)

   # macOS
   brew services list

   # Linux
   sudo systemctl status postgresql
   ```

2. Start PostgreSQL if not running:
   ```bash
   # Windows
   net start postgresql-x64-15

   # macOS
   brew services start postgresql@15

   # Linux
   sudo systemctl start postgresql
   ```

### Issue 2: "Authentication Failed"

**Symptoms:**
```
Error: password authentication failed for user "postgres"
```

**Solutions:**
1. Verify password in .env file
2. Reset PostgreSQL password:
   ```bash
   # Windows (as Administrator)
   psql -U postgres
   ALTER USER postgres WITH PASSWORD 'new_password';

   # Linux
   sudo -u postgres psql
   ALTER USER postgres WITH PASSWORD 'new_password';
   ```

### Issue 3: "Database Does Not Exist"

**Symptoms:**
```
Error: database "afro_db" does not exist
```

**Solution:**
```bash
psql -U postgres
CREATE DATABASE afro_db;
\q
```

### Issue 4: "Port Already in Use"

**Symptoms:**
```
Error: Port 5432 is already in use
```

**Solutions:**
1. Check what's using the port:
   ```bash
   # Windows
   netstat -ano | findstr :5432

   # macOS/Linux
   lsof -i :5432
   ```

2. Either:
   - Stop the conflicting service
   - Or change PostgreSQL port in postgresql.conf

### Issue 5: "Too Many Connections"

**Symptoms:**
```
Error: sorry, too many clients already
```

**Solution:**
Edit postgresql.conf:
```
max_connections = 100
```

Then restart PostgreSQL.

---

## Database Management Tools

### 1. pgAdmin 4 (GUI - Recommended)
- **Website**: https://www.pgadmin.org/
- **Features**: Visual query builder, table editor, backup/restore
- **Best for**: Beginners, visual database management

### 2. DBeaver (GUI - Cross-platform)
- **Website**: https://dbeaver.io/
- **Features**: Multi-database support, ER diagrams, data export
- **Best for**: Advanced users, multiple databases

### 3. psql (Command Line)
- **Built-in**: Comes with PostgreSQL
- **Features**: Fast, scriptable, powerful
- **Best for**: Developers, automation

### 4. TablePlus (GUI - Paid)
- **Website**: https://tableplus.com/
- **Features**: Modern UI, fast, multi-database
- **Best for**: Professional developers

---

## Backup & Restore

### Create Backup

```bash
# Full database backup
pg_dump -U postgres -d afro_db -F c -f afro_db_backup.dump

# SQL format backup
pg_dump -U postgres -d afro_db > afro_db_backup.sql
```

### Restore Backup

```bash
# From custom format
pg_restore -U postgres -d afro_db afro_db_backup.dump

# From SQL format
psql -U postgres -d afro_db < afro_db_backup.sql
```

---

## Performance Optimization

### 1. Create Indexes

```sql
-- Index on frequently queried fields
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_firebase_uid ON users(firebaseUid);
CREATE INDEX idx_appointments_user_id ON appointments(userId);
CREATE INDEX idx_appointments_barber_id ON appointments(barberId);
CREATE INDEX idx_appointments_date ON appointments(appointmentDate);
CREATE INDEX idx_payments_appointment_id ON payments(appointmentId);
```

### 2. Analyze Tables

```sql
-- Update statistics for query planner
ANALYZE users;
ANALYZE appointments;
ANALYZE payments;
```

### 3. Vacuum Database

```sql
-- Clean up dead rows
VACUUM ANALYZE;
```

---

## Security Best Practices

### 1. Use Strong Passwords
```bash
# Generate secure password
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. Limit Database User Permissions
```sql
-- Create limited user
CREATE USER app_user WITH ENCRYPTED PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE afro_db TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
```

### 3. Enable SSL (Production)
```env
DB_SSL=true
DB_SSL_REJECT_UNAUTHORIZED=false
```

### 4. Use Environment Variables
- Never commit .env file to git
- Use different credentials for dev/staging/production
- Rotate passwords regularly

---

## Production Deployment

### Managed PostgreSQL Services

#### 1. AWS RDS
- **Website**: https://aws.amazon.com/rds/postgresql/
- **Pros**: Fully managed, automatic backups, scaling
- **Setup**: Create RDS instance, update .env with connection details

#### 2. Google Cloud SQL
- **Website**: https://cloud.google.com/sql/postgresql
- **Pros**: Integrated with GCP, automatic backups
- **Setup**: Create Cloud SQL instance, configure connection

#### 3. Azure Database for PostgreSQL
- **Website**: https://azure.microsoft.com/en-us/services/postgresql/
- **Pros**: Integrated with Azure, high availability
- **Setup**: Create Azure PostgreSQL, update connection string

#### 4. Heroku Postgres
- **Website**: https://www.heroku.com/postgres
- **Pros**: Easy setup, free tier available
- **Setup**: Add Heroku Postgres addon, use DATABASE_URL

#### 5. DigitalOcean Managed Databases
- **Website**: https://www.digitalocean.com/products/managed-databases
- **Pros**: Simple, affordable, good performance
- **Setup**: Create managed database, update connection details

### Production Configuration

```env
NODE_ENV=production
DB_HOST=your-production-db-host.com
DB_PORT=5432
DB_USERNAME=production_user
DB_PASSWORD=very_secure_production_password
DB_NAME=afro_db_production
DB_SSL=true
```

---

## Monitoring & Maintenance

### 1. Monitor Connection Pool
```sql
SELECT * FROM pg_stat_activity;
```

### 2. Check Database Size
```sql
SELECT pg_size_pretty(pg_database_size('afro_db'));
```

### 3. Monitor Slow Queries
```sql
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### 4. Regular Maintenance Schedule
- Daily: Monitor logs and performance
- Weekly: Analyze tables, check disk space
- Monthly: Full backup, review indexes
- Quarterly: Security audit, password rotation

---

## Quick Start Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `afro_db` created
- [ ] Backend .env file configured
- [ ] Dependencies installed (`npm install`)
- [ ] Backend started (`npm run start:dev`)
- [ ] Health check passes (http://localhost:3001/health)
- [ ] API docs accessible (http://localhost:3001/api/docs)
- [ ] Tables created (check with `\dt` in psql)
- [ ] Test API endpoint works
- [ ] Backup strategy in place

---

## Support & Resources

### Official Documentation
- PostgreSQL: https://www.postgresql.org/docs/
- TypeORM: https://typeorm.io/
- NestJS: https://docs.nestjs.com/

### Community
- PostgreSQL Slack: https://postgres-slack.herokuapp.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/postgresql
- Reddit: https://www.reddit.com/r/PostgreSQL/

---

## Conclusion

You now have a complete guide to:
✅ Install PostgreSQL
✅ Create and configure the database
✅ Connect the backend to PostgreSQL
✅ Verify the connection
✅ Manage and maintain the database
✅ Deploy to production

Your AFRO Barber Shop backend is now ready to store and manage data with PostgreSQL!

---

**Last Updated**: March 8, 2026
**Version**: 1.0.0
**Status**: Complete ✅
