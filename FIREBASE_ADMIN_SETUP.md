# Firebase Admin SDK Setup Guide

## Overview
Your Firebase project is already configured in the mobile apps. Now you need to set up Firebase Admin SDK for the backend to enable server-side authentication and operations.

## Your Firebase Project Details
- **Project ID**: `afro-ce148`
- **Messaging Sender ID**: `766685133984`
- **Storage Bucket**: `afro-ce148.firebasestorage.app`
- **Auth Domain**: `afro-ce148.firebaseapp.com`

## Step 1: Get Firebase Admin Service Account Credentials

### Option A: Using Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: `afro-ce148`

2. **Navigate to Project Settings**
   - Click the gear icon ⚙️ next to "Project Overview"
   - Select "Project settings"

3. **Go to Service Accounts Tab**
   - Click on the "Service accounts" tab
   - You should see "Firebase Admin SDK" section

4. **Generate New Private Key**
   - Click "Generate new private key" button
   - Confirm by clicking "Generate key"
   - A JSON file will be downloaded (e.g., `afro-ce148-firebase-adminsdk-xxxxx.json`)

5. **Extract Credentials from JSON**
   The downloaded JSON file contains:
   ```json
   {
     "type": "service_account",
     "project_id": "afro-ce148",
     "private_key_id": "...",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
     "client_email": "firebase-adminsdk-xxxxx@afro-ce148.iam.gserviceaccount.com",
     "client_id": "...",
     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
     "token_uri": "https://oauth2.googleapis.com/token",
     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
     "client_x509_cert_url": "..."
   }
   ```

### Option B: Using Firebase CLI

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Get service account
firebase projects:list
firebase serviceaccounts:list --project afro-ce148
```

## Step 2: Update Backend .env File

Open `backend/.env` and update the Firebase section with the values from the downloaded JSON:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=afro-ce148
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@afro-ce148.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Actual-Private-Key-Here\n-----END PRIVATE KEY-----\n"
FIREBASE_DATABASE_URL=https://afro-ce148.firebaseio.com
```

### Important Notes:

1. **FIREBASE_CLIENT_EMAIL**: Copy the `client_email` value from the JSON file
   - Format: `firebase-adminsdk-xxxxx@afro-ce148.iam.gserviceaccount.com`

2. **FIREBASE_PRIVATE_KEY**: Copy the `private_key` value from the JSON file
   - Keep the quotes around the entire key
   - Keep the `\n` characters (they represent line breaks)
   - The key should start with `-----BEGIN PRIVATE KEY-----\n`
   - The key should end with `\n-----END PRIVATE KEY-----\n`

3. **Example of properly formatted private key**:
   ```env
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n...more lines...\n-----END PRIVATE KEY-----\n"
   ```

## Step 3: Update Docker Compose (if using Docker)

If you're using Docker, the backend container will automatically pick up the updated .env file. Just restart the backend service:

```bash
# Restart backend container
docker-compose restart backend

# Or rebuild and restart
docker-compose up -d --build backend
```

## Step 4: Verify Backend Connection

### Check Backend Logs
```bash
# If using Docker
docker-compose logs backend

# If running locally
npm run start:dev
```

### Test Health Endpoint
```bash
# Check if backend is running
curl http://localhost:3001/health

# Expected response:
{
  "status": "ok",
  "info": {
    "database": { "status": "up" },
    "memory_heap": { "status": "up" },
    "memory_rss": { "status": "up" },
    "disk": { "status": "up" }
  }
}
```

### Test Firebase Authentication
```bash
# Test user registration endpoint
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "phoneNumber": "+251912345678",
    "role": "customer"
  }'
```

## Step 5: Security Best Practices

### 1. Keep Service Account JSON Secure
- **Never commit** the service account JSON file to Git
- Store it securely (password manager, secure vault)
- Add to `.gitignore`:
  ```
  *-firebase-adminsdk-*.json
  ```

### 2. Environment Variables
- The `.env` file is already in `.gitignore`
- Never share or commit `.env` files
- Use different service accounts for development and production

### 3. Service Account Permissions
- The Firebase Admin SDK service account has full access to your Firebase project
- Only use it on the backend server
- Never expose these credentials in client-side code

### 4. Rotate Keys Regularly
- Generate new service account keys periodically
- Delete old keys from Firebase Console after rotation

## Troubleshooting

### Error: "Failed to parse private key"
- Make sure the private key is properly formatted with `\n` characters
- Ensure the key is wrapped in double quotes
- Check that there are no extra spaces or line breaks

### Error: "Invalid service account"
- Verify the `client_email` matches the one from Firebase Console
- Ensure the `project_id` is correct (`afro-ce148`)
- Check that the service account hasn't been deleted

### Error: "Permission denied"
- The service account needs proper permissions
- Go to Firebase Console → Project Settings → Service Accounts
- Verify the service account has "Firebase Admin SDK" role

### Backend Won't Start
```bash
# Check Docker logs
docker-compose logs backend

# Check if PostgreSQL is running
docker-compose ps

# Restart all services
docker-compose down
docker-compose up -d
```

## Next Steps

After setting up Firebase Admin SDK:

1. ✅ Backend can verify Firebase tokens from mobile apps
2. ✅ Backend can create/manage users server-side
3. ✅ Backend can send push notifications via FCM
4. ✅ Backend can access Firebase Storage
5. ✅ Backend can use Firebase Realtime Database (if needed)

## Quick Reference

### Current Configuration Status
- ✅ Firebase Project ID: `afro-ce148`
- ✅ Database URL: `https://afro-ce148.firebaseio.com`
- ⏳ Client Email: **Needs to be updated from service account JSON**
- ⏳ Private Key: **Needs to be updated from service account JSON**

### Files to Update
1. `backend/.env` - Add service account credentials
2. Restart backend service
3. Test authentication endpoints

### Support Links
- Firebase Console: https://console.firebase.google.com/project/afro-ce148
- Firebase Admin SDK Docs: https://firebase.google.com/docs/admin/setup
- NestJS Firebase Integration: https://docs.nestjs.com/techniques/authentication
