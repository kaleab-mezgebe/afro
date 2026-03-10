# Firebase Email Link Authentication Setup Guide

This guide will help you configure Firebase Email Link (passwordless) authentication for the admin panel.

## 🔥 Firebase Console Configuration

### Step 1: Enable Email/Password Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `afro-ce148`
3. Navigate to **Authentication** > **Sign-in method**
4. Click on **Email/Password** provider
5. Enable **Email/Password** if not already enabled
6. **Important**: Enable **Email link (passwordless sign-in)**
7. Click **Save**

### Step 2: Configure Authorized Domains

1. In the same **Sign-in method** tab, scroll down to **Authorized domains**
2. Add the following domains:
   - `localhost` (for development)
   - `your-production-domain.com` (replace with your actual domain)
3. Click **Add domain** for each
4. Save the configuration

### Step 3: Create Admin Users

1. Go to **Authentication** > **Users**
2. Click **Add user**
3. Enter admin email: `admin@afro.com`
4. Set a temporary password (will be removed after email link setup)
5. Click **Add user**

## 🛠️ Code Implementation

### Files Created

1. **`src/lib/emailAuth.ts`** - Email link authentication service
2. **`src/app/auth/email-link/page.tsx`** - Email link request page
3. **`src/app/auth/complete/page.tsx`** - Email link completion page
4. **`enable-email-link-auth.js`** - Setup and testing script

### Configuration

Update the `actionCodeSettings` in `src/lib/emailAuth.ts`:

```typescript
const actionCodeSettings: ActionCodeSettings = {
  url: process.env.NODE_ENV === 'production' 
    ? 'https://your-domain.com/admin/auth/complete' 
    : 'http://localhost:3000/auth/complete',
  handleCodeInApp: true,
  iOS: {
    bundleId: 'com.afro.admin'  // Update if you have iOS app
  },
  android: {
    packageName: 'com.afro.admin',  // Update if you have Android app
    installApp: true,
    minimumVersion: '12'
  }
};
```

### Admin Email Validation

Customize the `isValidAdminEmail` function in `emailAuth.ts`:

```typescript
function isValidAdminEmail(email: string): boolean {
  const adminDomains = [
    'afro.com',
    'admin.afro.com',
    'yourdomain.com'  // Add your domains
  ];
  
  const adminEmails = [
    'admin@afro.com',
    'support@afro.com',
    'manager@afro.com'  // Add specific emails
  ];
  
  // Check whitelist logic...
}
```

## 🧪 Testing

### Run the Setup Script

```bash
cd admin-panel
node enable-email-link-auth.js
```

This script will:
- Check Firebase configuration
- Create admin user if needed
- Test email link functionality
- Provide setup instructions

### Manual Testing

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Navigate to: `http://localhost:3000/auth/email-link`

3. Enter admin email: `admin@afro.com`

4. Check your email for the sign-in link

5. Click the link to complete authentication

## 🔗 URL Routes

- **Email Link Request**: `/auth/email-link`
- **Email Link Completion**: `/auth/complete`
- **Regular Login**: `/login`
- **Dashboard**: `/dashboard`

## 🔒 Security Features

### Email Validation
- Whitelist of admin domains
- Specific admin email addresses
- Email format validation

### Link Security
- 24-hour expiration
- One-time use links
- Device verification
- Secure token handling

### Error Handling
- Invalid/expired links
- Unauthorized emails
- Network failures
- User-friendly messages

## 🚀 Production Deployment

### Environment Variables

Ensure these are set in production:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
```

### Domain Configuration

1. Add your production domain to Firebase authorized domains
2. Update the `actionCodeSettings.url` in `emailAuth.ts`
3. Configure SSL/HTTPS for security

### Email Template Customization

1. Go to Firebase Console > Authentication > Templates
2. Customize the **Email link sign-in** template
3. Add your branding and styling
4. Test the email appearance

## 📧 Email Template

Firebase will send emails with this structure:

```
Subject: Sign in to AFRO Admin

Hello,

Follow this link to sign in to your AFRO Admin account:
[Sign in to AFRO Admin]

If you didn't request this link, you can ignore this email.

Your link will expire in 24 hours.

Thanks,
The AFRO Team
```

## 🔧 Troubleshooting

### Common Issues

1. **"Operation not allowed" error**
   - Enable Email/Password provider in Firebase Console
   - Enable Email link (passwordless sign-in)

2. **"Invalid email" error**
   - Check email format
   - Verify email is in admin whitelist

3. **"Invalid action code" error**
   - Link may be expired (24 hours)
   - Link may have been used already
   - Check URL parameters

4. **Domain not authorized**
   - Add domain to Firebase authorized domains
   - Include both `localhost` and production domains

### Debug Mode

Enable debug logging in `emailAuth.ts`:

```typescript
// Add at the top of functions
console.log('Debug: Email link auth attempt', { email, url });
```

### Testing Script Output

The `enable-email-link-auth.js` script provides detailed diagnostics:

```bash
🔥 Firebase Email Link Authentication Setup

Project ID: afro-ce148
API Key: AIzaSyBu3dwqiJ9Nd5A5...

🔍 Checking Firebase Authentication configuration...
✅ Firebase project is accessible

📋 Current Sign-in Methods:
   Email/Password: ✅ Enabled
   Email Link: ✅ Enabled

🧪 Testing Email Link authentication for: admin@afro.com
✅ Email link sent successfully!
```

## 📱 Mobile App Integration

If you have mobile apps, update the configuration:

```typescript
// In emailAuth.ts
iOS: {
  bundleId: 'com.afro.admin.ios'
},
android: {
  packageName: 'com.afro.admin.android',
  installApp: true,
  minimumVersion: '12'
}
```

## 🎯 Next Steps

1. **Run the setup script**: `node enable-email-link-auth.js`
2. **Configure Firebase Console** following the steps above
3. **Test the authentication flow** with admin emails
4. **Customize email templates** in Firebase Console
5. **Deploy to production** with proper domain configuration

## 📞 Support

If you encounter issues:

1. Check the Firebase Console for error logs
2. Run the diagnostic script for detailed information
3. Verify all configuration steps are completed
4. Test with different admin email addresses

The email link authentication provides a secure, user-friendly way for admins to access the panel without remembering passwords.