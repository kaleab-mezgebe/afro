# Firebase Push Notifications Setup Guide

## What I've Done

### 1. Added Dependencies
- `firebase_messaging: ^14.7.10` - For FCM integration
- `flutter_local_notifications: ^17.0.0` - For local notification display

### 2. Created Firebase Messaging Service
Location: `lib/core/services/firebase_messaging_service.dart`

Features:
- Request notification permissions
- Get and manage FCM tokens
- Handle foreground, background, and terminated state notifications
- Display local notifications when app is in foreground
- Topic subscription support
- Notification tap handling

### 3. Updated Configuration Files
- `lib/main.dart` - Initialize messaging service on app start
- `android/app/src/main/AndroidManifest.xml` - Added POST_NOTIFICATIONS permission

### 4. Created Controllers and UI
- `NotificationController` - Manage notification state and subscriptions
- `NotificationSettingsPage` - UI to view FCM token and settings

## Next Steps to Complete Setup

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Firebase Console Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `afro-ce148`
3. Navigate to **Cloud Messaging** in the left sidebar
4. Enable Cloud Messaging API (if not already enabled)

### Step 3: Test Notifications

#### Option A: Using Firebase Console (Easiest)
1. Run your app on a device/emulator
2. Copy the FCM token from the app (use NotificationSettingsPage)
3. Go to Firebase Console → Cloud Messaging → Send test message
4. Paste the FCM token
5. Add title and body
6. Click "Test"

#### Option B: Using REST API
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test message"
    },
    "data": {
      "type": "booking_update",
      "booking_id": "123"
    }
  }'
```

### Step 4: Backend Integration

When a user logs in, send their FCM token to your backend:

```dart
// In your auth controller after successful login
final notificationController = Get.find<NotificationController>();
String? fcmToken = notificationController.getFCMToken();

// Send to your backend
await yourApiService.updateUserFCMToken(userId, fcmToken);
```

### Step 5: iOS Setup (If Supporting iOS)

1. Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

2. Enable Push Notifications capability in Xcode
3. Upload APNs certificate to Firebase Console

## Notification Types You Can Send

### 1. Booking Confirmation
```json
{
  "notification": {
    "title": "Booking Confirmed!",
    "body": "Your appointment with John's Barbershop is confirmed for 2:00 PM"
  },
  "data": {
    "type": "booking_confirmed",
    "booking_id": "123",
    "screen": "booking_details"
  }
}
```

### 2. Booking Reminder
```json
{
  "notification": {
    "title": "Appointment Reminder",
    "body": "Your appointment is in 1 hour"
  },
  "data": {
    "type": "booking_reminder",
    "booking_id": "123"
  }
}
```

### 3. Promotional Offers
```json
{
  "notification": {
    "title": "Special Offer!",
    "body": "Get 20% off your next haircut"
  },
  "data": {
    "type": "promotion",
    "promo_code": "SAVE20"
  }
}
```

## Topic Subscriptions

Subscribe users to topics for targeted notifications:

```dart
// Subscribe to all users topic
await FirebaseMessagingService().subscribeToTopic('all_users');

// Subscribe to user-specific topic
await FirebaseMessagingService().subscribeToTopic('user_${userId}');

// Subscribe to location-based topic
await FirebaseMessagingService().subscribeToTopic('city_newyork');
```

## Handling Notification Taps

Update `_handleNotificationTap` in `firebase_messaging_service.dart`:

```dart
void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  
  switch (data['type']) {
    case 'booking_confirmed':
    case 'booking_reminder':
      Get.toNamed(AppRoutes.bookingDetails, arguments: data['booking_id']);
      break;
    case 'promotion':
      Get.toNamed(AppRoutes.offers);
      break;
    default:
      Get.toNamed(AppRoutes.home);
  }
}
```

## Testing Checklist

- [ ] App receives notifications when in foreground
- [ ] App receives notifications when in background
- [ ] App receives notifications when terminated
- [ ] Tapping notification opens the app
- [ ] FCM token is generated and displayed
- [ ] Notifications show with correct title and body
- [ ] Custom notification sound works (if configured)
- [ ] Topic subscriptions work correctly

## Common Issues

### Issue: Notifications not received
- Check internet connection
- Verify FCM token is valid
- Check Firebase Console for delivery status
- Ensure google-services.json is up to date

### Issue: Notifications not showing in foreground
- Local notifications plugin is handling this
- Check notification channel is created (Android)

### Issue: Token is null
- Ensure Firebase is initialized before messaging service
- Check notification permissions are granted
- Try uninstalling and reinstalling the app

## Server-Side Implementation

Your backend should:
1. Store user FCM tokens in database
2. Send notifications using Firebase Admin SDK
3. Handle token refresh/updates
4. Remove invalid tokens

Example Node.js code:
```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendNotification(token, title, body, data) {
  const message = {
    notification: { title, body },
    data: data,
    token: token
  };
  
  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent:', response);
  } catch (error) {
    console.error('Error sending:', error);
  }
}
```

## Resources

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Local Notifications Plugin](https://pub.dev/packages/flutter_local_notifications)
