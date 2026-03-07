# Firebase User Registration Guide

## Overview
This guide shows how to register users to Firebase Firestore database with complete profile information.

## What's Implemented

### 1. Firebase User Service (`lib/core/services/firebase_user_service.dart`)
- **saveUserProfile()** - Basic user profile after auth
- **saveUserRegistration()** - Complete registration with all profile fields
- **getUserProfile()** - Retrieve user data from Firestore
- **updateUserProfile()** - Update existing user profile
- **deleteUserProfile()** - Remove user from Firestore
- **userProfileStream()** - Real-time profile updates

### 2. Enhanced User Entity (`lib/domain/entities/user.dart`)
Extended to include registration fields:
- firstName, lastName
- location, gender, dateOfBirth
- hairType, skinType
- preferredServices (List<String>)

### 3. Firebase Auth Repository (`lib/data/repositories/firebase_auth_repository_impl.dart`)
Full Firebase integration with:
- Email/password authentication
- Profile management
- Local storage caching
- Real-time auth state changes

### 4. Updated Registration Controller (`lib/features/auth/controllers/user_registration_controller.dart`)
Now uses Firebase to save complete user profiles.

## How to Use

### Phone Registration Flow
```dart
// 1. Phone Authentication (already implemented)
final phoneController = Get.put(PhoneAuthController());
phoneController.proceed(); // Sends OTP

// 2. OTP Verification (automatic navigation)
// After successful OTP, user is authenticated

// 3. Complete Registration
final registrationController = Get.put(UserRegistrationController());
registrationController.submitRegistration(); // Saves to Firestore
```

### Social Registration Flow
```dart
// 1. Google Sign-In
final phoneController = Get.put(PhoneAuthController());
phoneController.loginWithGoogle();

// 2. Complete Registration (same as above)
```

### Email Registration Flow
```dart
// 1. Email/Password Registration
final authController = Get.put(AuthController());
authController.submit(); // Creates Firebase Auth user

// 2. Complete Registration (same as above)
```

## Database Structure

### Firestore Collection: `users`
```javascript
{
  "id": "firebase_uid",
  "name": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "avatar": "https://...",
  "isEmailVerified": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  
  // Extended profile fields
  "firstName": "John",
  "lastName": "Doe",
  "location": "New York, USA",
  "gender": "male",
  "dateOfBirth": "1990-01-01",
  "hairType": "curly",
  "skinType": "oily",
  "preferredServices": ["haircut", "beard_trim", "facial"]
}
```

## Security Rules (Add to Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow read access for authenticated users to basic profile info
      allow read: if request.auth != null && 
        request.resource.data.keys().hasAll(['name', 'avatar']);
    }
    
    // Public read access for service providers and other collections
    match /{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

## Testing the Registration

1. **Enable Firebase Services:**
   - Authentication (Phone, Google, Facebook, Email)
   - Firestore Database
   - Storage (for profile images)

2. **Test Phone Registration:**
   - Enter phone number
   - Verify OTP
   - Fill registration form
   - Check Firestore for new user document

3. **Test Social Registration:**
   - Click Google/Facebook login
   - Complete registration form
   - Verify data in Firestore

## Next Steps

1. **Add Image Upload:** Implement Firebase Storage for profile pictures
2. **Add Validation:** Server-side validation for registration data
3. **Add Email Verification:** Send verification emails
4. **Add Profile Editing:** Allow users to update their profiles
5. **Add User Search:** Implement user lookup functionality

## Troubleshooting

- **"No authenticated user found"**: Ensure user completed authentication before registration
- **Firestore permissions denied**: Check security rules in Firebase Console
- **Missing fields**: Verify all required fields are included in registration form
- **Network errors**: Check internet connection and Firebase configuration
