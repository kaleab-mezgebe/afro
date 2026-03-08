# AFRO Admin Panel - Setup Guide

Complete setup instructions for the admin panel.

## Prerequisites

- Node.js 18+ installed
- Backend API running on port 3001
- Firebase project configured
- Admin user created in Firebase

## Installation Steps

### 1. Install Dependencies

```bash
cd admin-panel
npm install
```

### 2. Configure Environment Variables

Create `.env.local` file:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

Get these values from:
- Firebase Console → Project Settings → General → Your apps → SDK setup and configuration

### 3. Create Admin User in Firebase

1. Go to Firebase Console → Authentication
2. Add a new user with email/password
3. Note the user's UID
4. In Firebase Console → Firestore Database, create:
   - Collection: `users`
   - Document ID: [user's UID]
   - Fields:
     ```json
     {
       "email": "admin@afro.com",
       "role": "admin",
       "displayName": "Admin User",
       "createdAt": [current timestamp]
     }
     ```

### 4. Configure Backend for Admin Role

Ensure your backend recognizes the admin role. The admin user should have access to all `/admin/*` endpoints.

### 5. Start Development Server

```bash
npm run dev
```

Admin panel will be available at: http://localhost:3002

### 6. Login

Use the admin credentials you created:
- Email: admin@afro.com
- Password: [your password]

## Troubleshooting

### Cannot Connect to Backend

- Verify backend is running: `curl http://localhost:3001/api/v1/health`
- Check CORS settings in backend allow requests from `http://localhost:3002`
- Verify API_URL in `.env.local`

### Authentication Errors

- Verify Firebase configuration in `.env.local`
- Check admin user exists in Firebase Authentication
- Verify admin role is set in Firestore
- Clear browser cache and cookies

### Build Errors

```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Delete .next folder
rm -rf .next
npm run dev
```

### API Errors

- Check browser console for detailed error messages
- Verify Firebase token is being sent in request headers
- Check backend logs for authentication/authorization errors

## Production Deployment

### Build for Production

```bash
npm run build
npm start
```

### Environment Variables for Production

Update `.env.local` with production values:

```env
NEXT_PUBLIC_API_URL=https://api.yourapp.com/api/v1
NEXT_PUBLIC_FIREBASE_API_KEY=your_production_api_key
# ... other production Firebase config
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

Add environment variables in Vercel dashboard:
- Project Settings → Environment Variables
- Add all variables from `.env.local`

### Deploy to Other Platforms

- **Netlify**: Connect GitHub repo, set build command to `npm run build`
- **AWS Amplify**: Connect repo, configure build settings
- **DigitalOcean App Platform**: Create app from GitHub repo
- **Self-hosted**: Build and run with PM2 or Docker

## Features Overview

### Dashboard
- System overview with key metrics
- Recent activity feed
- Quick action buttons

### User Management
- List all users (customers, providers, admins)
- Search and filter users
- Suspend/activate accounts
- View user details

### Provider Management
- Approve/reject provider registrations
- Verify provider documents
- Manage provider shops
- View provider analytics

### Customer Management
- View customer profiles
- View booking history
- Handle customer complaints

### Appointment Management
- View all appointments
- Filter by status, date, provider
- Monitor appointment trends

### Analytics
- Revenue trends (charts)
- User growth metrics
- Appointment statistics
- System-wide analytics

### Settings
- Configure system settings
- Set commission rates
- Manage booking policies

## Security Notes

- Admin panel requires authentication
- All API calls include Firebase JWT token
- Role-based access control enforced
- Sensitive data is masked in UI
- All actions are logged for audit

## Support

For issues:
1. Check backend logs: `docker logs [backend-container]`
2. Check browser console for errors
3. Verify Firebase configuration
4. Check API documentation: http://localhost:3001/api/docs

---

**Status**: ✅ Ready for Use
**Port**: 3002
**Backend**: http://localhost:3001
**Docs**: http://localhost:3001/api/docs
