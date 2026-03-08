# AFRO Booking System - Production Setup Guide

## 🚀 Complete Setup Instructions

This guide will walk you through setting up all the critical components needed for production.

---

## 1. Firebase Configuration (CRITICAL)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `afro-booking` (or your choice)
4. Enable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Enable Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable these providers:
   - ✅ Email/Password
   - ✅ Phone (for OTP)
   - ✅ Google (optional)
   - ✅ Facebook (optional)

### Step 3: Get Firebase Credentials
1. Go to **Project Settings** (gear icon) → **Service accounts**
2. Click "Generate new private key"
3. Download the JSON file
4. Extract these values:
   - `project_id`
   - `private_key`
   - `client_email`

### Step 4: Configure Backend
Create `backend/.env` file:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Key-Here\n-----END PRIVATE KEY-----\n"
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

**Important**: Keep the `\n` in the private key!

### Step 5: Configure Mobile Apps
1. **Android**: Download `google-services.json`
   - Place in: `android/app/google-services.json`
   
2. **iOS**: Download `GoogleService-Info.plist`
   - Place in: `ios/Runner/GoogleService-Info.plist`

### Step 6: Configure Admin Panel
Update `admin-panel/.env.local`:
```env
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789:web:abcdef
```

---

## 2. Environment Variables Setup

### Backend `.env` File
Copy `backend/.env.example` to `backend/.env` and fill in:

```env
# Application
NODE_ENV=production
PORT=3001
APP_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com
ADMIN_URL=https://admin.yourdomain.com

# Database (already configured via Docker)
DB_HOST=afro_postgres
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_secure_password_here
DB_NAME=afro_db

# JWT (GENERATE NEW SECRETS!)
JWT_SECRET=your-super-secret-jwt-key-min-32-characters
JWT_REFRESH_SECRET=your-super-secret-refresh-key-min-32-characters

# Email (Choose one provider)
# Option 1: Gmail
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-specific-password
SMTP_FROM_EMAIL=noreply@yourdomain.com

# Option 2: SendGrid
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key

# AWS S3 (for image uploads)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=afro-booking-uploads

# Payment Gateways
STRIPE_SECRET_KEY=sk_live_your-key
STRIPE_PUBLISHABLE_KEY=pk_live_your-key
CHAPA_SECRET_KEY=CHASECK-your-key
```

### Generate Secure Secrets
```bash
# Generate JWT secrets (run in terminal)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## 3. Email System Setup

### Option A: Gmail (Easiest for Testing)

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Other (Custom name)"
   - Enter "AFRO Booking"
   - Copy the 16-character password

3. **Configure**:
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password
```

### Option B: SendGrid (Recommended for Production)

1. **Sign up**: https://sendgrid.com/
2. **Create API Key**:
   - Go to Settings → API Keys
   - Create API Key with "Full Access"
   - Copy the key

3. **Configure**:
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.your-api-key-here
```

### Option C: AWS SES (Best for Scale)

1. **Sign up for AWS**
2. **Verify Domain** in SES
3. **Get SMTP Credentials**
4. **Configure**:
```env
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=your-smtp-username
SMTP_PASSWORD=your-smtp-password
```

### Test Email
```bash
# Start backend
cd backend
npm run start:dev

# Test email endpoint
curl -X POST http://localhost:3001/email/test \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","name":"Test User"}'
```

---

## 4. Image Upload Setup

### Option A: AWS S3 (Recommended)

1. **Create AWS Account**: https://aws.amazon.com/
2. **Create S3 Bucket**:
   - Go to S3 Console
   - Click "Create bucket"
   - Name: `afro-booking-uploads`
   - Region: `us-east-1` (or your choice)
   - Uncheck "Block all public access"
   - Create bucket

3. **Set Bucket Policy**:
   - Go to bucket → Permissions → Bucket Policy
   - Add this policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::afro-booking-uploads/*"
    }
  ]
}
```

4. **Create IAM User**:
   - Go to IAM → Users → Add User
   - Username: `afro-booking-uploader`
   - Access type: Programmatic access
   - Attach policy: `AmazonS3FullAccess`
   - Save Access Key ID and Secret Access Key

5. **Configure**:
```env
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=afro-booking-uploads
```

### Option B: Cloudinary (Alternative)

1. **Sign up**: https://cloudinary.com/
2. **Get Credentials** from Dashboard
3. **Configure**:
```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### Option C: Local Storage (Development Only)

```env
# No AWS/Cloudinary config needed
UPLOAD_DESTINATION=./uploads
```

Files will be saved locally in `backend/uploads/`

### Test Upload
```bash
# Test profile picture upload
curl -X POST http://localhost:3001/upload/profile-picture \
  -F "file=@/path/to/image.jpg" \
  -F "userId=test-user-123"
```

---

## 5. Payment Gateway Setup

### Stripe (International)

1. **Sign up**: https://stripe.com/
2. **Get API Keys**:
   - Dashboard → Developers → API keys
   - Copy "Publishable key" and "Secret key"
   - For testing, use test keys (starts with `pk_test_` and `sk_test_`)

3. **Configure**:
```env
STRIPE_SECRET_KEY=sk_test_your-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key
```

### Chapa (Ethiopia)

1. **Sign up**: https://chapa.co/
2. **Get API Key** from dashboard
3. **Configure**:
```env
CHAPA_SECRET_KEY=CHASECK_TEST-your-key
```

### Flutterwave (Africa)

1. **Sign up**: https://flutterwave.com/
2. **Get API Keys** from Settings
3. **Configure**:
```env
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-your-key
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-your-key
```

---

## 6. Push Notifications Setup

### Get FCM Server Key

1. Go to Firebase Console → Project Settings
2. Click "Cloud Messaging" tab
3. Copy "Server key"

### Configure Backend
```env
FCM_SERVER_KEY=your-fcm-server-key
ENABLE_PUSH_NOTIFICATIONS=true
```

### Test Notification
The mobile apps are already configured. Backend will send notifications automatically on:
- New booking
- Booking confirmation
- Booking reminder
- Booking cancellation

---

## 7. Database Backup Setup

### Automated Backups

Create `backend/scripts/backup-db.sh`:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR

docker exec afro_postgres pg_dump -U postgres afro_db > "$BACKUP_DIR/afro_db_$DATE.sql"

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "Backup completed: afro_db_$DATE.sql"
```

Make executable:
```bash
chmod +x backend/scripts/backup-db.sh
```

### Schedule Daily Backups (Linux/Mac)
```bash
# Add to crontab
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * /path/to/backend/scripts/backup-db.sh
```

---

## 8. SSL Certificate Setup

### Option A: Let's Encrypt (Free)

```bash
# Install certbot
sudo apt-get install certbot

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d api.yourdomain.com -d admin.yourdomain.com

# Certificates will be in:
# /etc/letsencrypt/live/yourdomain.com/
```

### Option B: Cloudflare (Free + CDN)

1. Sign up at https://cloudflare.com/
2. Add your domain
3. Update nameservers
4. Enable "Full (strict)" SSL
5. Done! Cloudflare handles SSL automatically

---

## 9. Docker Production Setup

### Update `docker-compose.yml` for Production

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: afro_postgres_prod
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: afro_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    container_name: afro_backend_prod
    restart: always
    ports:
      - "3001:3001"
    environment:
      NODE_ENV: production
    env_file:
      - ./backend/.env
    depends_on:
      - postgres

  admin:
    build: ./admin-panel
    container_name: afro_admin_prod
    restart: always
    ports:
      - "3002:3002"
    environment:
      NODE_ENV: production

volumes:
  postgres_data:
```

### Deploy
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 10. Monitoring Setup

### Health Check Endpoint
Already implemented at: `http://localhost:3001/health`

### Add Uptime Monitoring

**Option 1: UptimeRobot** (Free)
1. Sign up: https://uptimerobot.com/
2. Add monitor for: `https://api.yourdomain.com/health`
3. Get alerts via email/SMS

**Option 2: Pingdom** (Paid)
- More features, better analytics

---

## 11. Testing Checklist

### Before Going Live

- [ ] Firebase authentication works
- [ ] Email sending works (test all templates)
- [ ] Image upload works
- [ ] Payment gateway works (test mode)
- [ ] Push notifications work
- [ ] Database backups configured
- [ ] SSL certificate installed
- [ ] All environment variables set
- [ ] Docker containers running
- [ ] Health check endpoint responding
- [ ] Admin panel accessible
- [ ] Mobile apps can connect to API

### Test Complete Flow

1. **Customer Registration**
   ```bash
   # Register via mobile app or admin panel
   # Check: Welcome email received
   ```

2. **Provider Registration**
   ```bash
   # Register provider
   # Admin approves
   # Check: Approval email received
   ```

3. **Create Booking**
   ```bash
   # Customer books appointment
   # Check: Confirmation email sent
   # Check: Provider receives notification
   ```

4. **Upload Images**
   ```bash
   # Upload profile picture
   # Upload shop logo
   # Upload portfolio photos
   # Check: Images accessible via URL
   ```

5. **Process Payment**
   ```bash
   # Complete booking with payment
   # Check: Payment recorded in database
   # Check: Receipt email sent
   ```

---

## 12. Security Checklist

- [ ] Change all default passwords
- [ ] Use strong JWT secrets (32+ characters)
- [ ] Enable HTTPS only
- [ ] Set up CORS properly
- [ ] Enable rate limiting
- [ ] Regular security updates
- [ ] Database access restricted
- [ ] API keys in environment variables (not code)
- [ ] Firebase rules configured
- [ ] S3 bucket permissions correct

---

## 13. Performance Optimization

### Database
```sql
-- Add indexes for common queries
CREATE INDEX idx_appointments_date ON appointments(appointmentDate);
CREATE INDEX idx_shops_location ON shops(latitude, longitude);
CREATE INDEX idx_users_email ON users(email);
```

### Backend
- ✅ Connection pooling (already configured)
- ✅ Response caching (already configured)
- ✅ Rate limiting (already configured)

### Frontend
- Enable CDN for static assets
- Optimize images (WebP format)
- Enable gzip compression

---

## 14. Deployment Platforms

### Recommended Options

**Backend + Database**:
- AWS EC2 + RDS
- DigitalOcean Droplet + Managed Database
- Heroku (easiest, more expensive)
- Railway.app (modern, easy)

**Admin Panel**:
- Vercel (recommended for Next.js)
- Netlify
- AWS Amplify

**Mobile Apps**:
- Google Play Store (Android)
- Apple App Store (iOS)

---

## 15. Cost Estimation

### Monthly Costs (Production)

| Service | Cost | Notes |
|---------|------|-------|
| AWS EC2 (t3.medium) | $30-50 | Backend server |
| AWS RDS PostgreSQL | $50-100 | Database |
| AWS S3 | $5-20 | Image storage |
| Firebase | $0-25 | Auth + FCM (free tier) |
| SendGrid | $0-15 | Email (40k/month free) |
| Domain + SSL | $15/year | Domain registration |
| Stripe fees | 2.9% + $0.30 | Per transaction |
| **Total** | **$85-210/month** | |

### Alternative (Budget Option)

| Service | Cost | Notes |
|---------|------|-------|
| DigitalOcean Droplet | $12-24 | 2-4GB RAM |
| Managed PostgreSQL | $15-30 | 1GB RAM |
| Cloudinary | $0 | Free tier (25GB) |
| Firebase | $0 | Free tier |
| Gmail SMTP | $0 | Free |
| **Total** | **$27-54/month** | |

---

## 16. Launch Checklist

### Week Before Launch
- [ ] All features tested
- [ ] Load testing completed
- [ ] Backup system verified
- [ ] Monitoring configured
- [ ] Support email set up
- [ ] Terms of Service written
- [ ] Privacy Policy written
- [ ] App store listings prepared

### Launch Day
- [ ] Deploy to production
- [ ] Verify all services running
- [ ] Test critical flows
- [ ] Monitor error logs
- [ ] Be ready for support requests

### Week After Launch
- [ ] Monitor performance
- [ ] Collect user feedback
- [ ] Fix critical bugs
- [ ] Optimize based on usage
- [ ] Plan next features

---

## 17. Support & Maintenance

### Daily
- Check error logs
- Monitor uptime
- Respond to support tickets

### Weekly
- Review analytics
- Check database performance
- Update dependencies

### Monthly
- Security updates
- Performance optimization
- Feature planning
- Cost review

---

## 🎉 You're Ready to Launch!

Once you complete all the steps above, your AFRO Booking System will be production-ready!

### Quick Start Commands

```bash
# 1. Set up environment
cp backend/.env.example backend/.env
# Edit backend/.env with your credentials

# 2. Start services
docker-compose up -d

# 3. Run migrations
docker exec afro_backend npm run migration:run

# 4. Load sample data
docker exec -i afro_postgres psql -U postgres -d afro_db < add_sample_data_simple.sql

# 5. Test everything
curl http://localhost:3001/health
curl http://localhost:3002
```

### Need Help?

- Check logs: `docker-compose logs -f`
- Database access: `docker exec -it afro_postgres psql -U postgres -d afro_db`
- Backend shell: `docker exec -it afro_backend sh`

---

**Good luck with your launch! 🚀**
