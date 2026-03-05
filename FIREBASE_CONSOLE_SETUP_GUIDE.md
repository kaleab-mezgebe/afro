# 🔥 Firebase Console Setup Guide - Complete Walkthrough

## Your Firebase Project
- **Project ID**: afro-ce148
- **Project Name**: Afro
- **Console URL**: https://console.firebase.google.com/project/afro-ce148

---

## ✅ What's Already Done

You've already completed these steps:
- ✅ Firebase project created
- ✅ Android app registered (com.example.customer_app)
- ✅ google-services.json downloaded and added
- ✅ Firebase Authentication enabled (Phone, Google, Facebook)
- ✅ Firebase Cloud Messaging API enabled
- ✅ Firebase Installations API enabled
- ✅ API key restrictions configured

---

## 🎯 What You Need to Do in Firebase Console

### Step 1: Verify Cloud Messaging is Enabled

1. **Go to Firebase Console**:
   - URL: https://console.firebase.google.com/project/afro-ce148

2. **Navigate to Cloud Messaging**:
   - Click the gear icon (⚙️) next to "Project Overview"
   - Select "Project settings"
   - Go to the "Cloud Messaging" tab

3. **Verify you see**:
   - ✅ Sender ID: `766685133984`
   - ✅ Server key: (starts with "AAAA...")
   - ✅ Cloud Messaging API (V1): Enabled

4. **If not enabled**:
   - Click the three dots (⋮) menu
   - Click "Manage API in Google Cloud Console"
   - Click "Enable"

---

### Step 2: Send Your First Test Notification

#### Option A: Send to Specific Device (Recommended for Testing)

1. **Get your FCM Token**:
   - Run your app: `flutter run`
   - Look in console for: `FCM Token: xxxxxx`
   - Copy the entire token

2. **Go to Firebase Messaging**:
   - In Firebase Console, click "Engage" → "Messaging" (left sidebar)
   - Or direct link: https://console.firebase.google.com/project/afro-ce148/messaging

3. **Create Campaign**:
   - Click "Create your first campaign" or "New campaign"
   - Select "Firebase Notification messages"

4. **Fill Notification Details**:
   ```
   Notification title: Test Notification
   Notification text: Hello! This is your first notification
   Notification image: (optional - leave blank)
   ```

5. **Click "Next"**

6. **Select Target**:
   - Choose "Send test message"
   - In the popup, paste your FCM token
   - Click the "+" button to add it
   - Click "Test"

7. **Check Your Device**:
   - You should receive the notification immediately!
   - Check system tray
   - Open app and tap bell icon to see it in the list

#### Option B: Send to All Users (Topic-Based)

1. **Follow steps 1-4 above**

2. **Click "Next"**

3. **Select Target**:
   - Choose "Topic"
   - Enter: `all_users`
   - Click "Next"

4. **Scheduling** (optional):
   - Choose "Now" or schedule for later
   - Click "Next"

5. **Conversion events** (optional):
   - Skip this, click "Next"

6. **Additional options**:
   - Click "Additional options" to add custom data
   - Add key-value pairs:
     ```
     Key: type
     Value: booking (or promotion, reminder, update)
     ```

7. **Review and Publish**:
   - Click "Review"
   - Click "Publish"

---

### Step 3: Set Up Notification Templates (Optional but Recommended)

Create reusable notification templates for common scenarios:

#### Template 1: Booking Confirmation
```json
{
  "notification": {
    "title": "Booking Confirmed! 🎉",
    "body": "Your appointment is confirmed for {date} at {time}"
  },
  "data": {
    "type": "booking",
    "booking_id": "{booking_id}",
    "screen": "booking_details"
  }
}
```

#### Template 2: Appointment Reminder
```json
{
  "notification": {
    "title": "Appointment Reminder ⏰",
    "body": "Your appointment is in 1 hour at {location}"
  },
  "data": {
    "type": "reminder",
    "booking_id": "{booking_id}"
  }
}
```

#### Template 3: Special Offer
```json
{
  "notification": {
    "title": "Special Offer! 🎁",
    "body": "Get {discount}% off your next service. Use code: {promo_code}"
  },
  "data": {
    "type": "promotion",
    "promo_code": "{promo_code}",
    "discount": "{discount}"
  }
}
```

#### Template 4: New Message
```json
{
  "notification": {
    "title": "New Message from {specialist_name}",
    "body": "{message_preview}"
  },
  "data": {
    "type": "update",
    "screen": "messages",
    "specialist_id": "{specialist_id}"
  }
}
```

---

### Step 4: Configure Topic Subscriptions

Topics allow you to send notifications to groups of users.

#### Common Topics to Set Up:

1. **all_users** - All app users
2. **android_users** - Android users only
3. **ios_users** - iOS users only
4. **premium_users** - Premium subscribers
5. **city_newyork** - Users in specific locations
6. **new_offers** - Users who opted in for offers

#### How to Use Topics:

Users are automatically subscribed to `all_users` when they open the app (already configured in your code).

To subscribe to more topics, add in your code:
```dart
await FirebaseMessagingService().subscribeToTopic('new_offers');
```

To send to a topic in Firebase Console:
1. Create campaign
2. Select "Topic" as target
3. Enter topic name (e.g., "all_users")
4. Publish

---

### Step 5: Monitor Notification Performance

1. **Go to Messaging Dashboard**:
   - Firebase Console → Messaging
   - You'll see all your campaigns

2. **View Campaign Stats**:
   - Click on any campaign to see:
     - ✅ Sent: How many notifications were sent
     - ✅ Opened: How many users opened the notification
     - ✅ Impressions: How many times notification was seen
     - ✅ Conversion rate: Percentage of users who took action

3. **Export Data**:
   - Click "Export to BigQuery" for detailed analytics

---

### Step 6: Set Up Server Key for Backend (Important!)

If you have a backend server that will send notifications:

1. **Get Server Key**:
   - Firebase Console → Project Settings → Cloud Messaging
   - Copy the "Server key" (starts with "AAAA...")

2. **Store Securely**:
   - ⚠️ NEVER commit this key to your code repository
   - Store in environment variables
   - Use secret management (AWS Secrets Manager, etc.)

3. **Use in Backend**:
   ```javascript
   // Node.js example
   const admin = require('firebase-admin');
   
   admin.initializeApp({
     credential: admin.credential.cert({
       projectId: 'afro-ce148',
       clientEmail: 'firebase-adminsdk-fbsvc@afro-ce148.iam.gserviceaccount.com',
       privateKey: process.env.FIREBASE_PRIVATE_KEY
     })
   });
   ```

---

### Step 7: Configure Notification Channels (Android)

Already configured in your app code, but you can customize:

1. **High Priority Notifications**:
   - Booking confirmations
   - Appointment reminders
   - Important updates

2. **Normal Priority**:
   - Promotional offers
   - General updates

3. **Low Priority**:
   - Marketing messages
   - Tips and tricks

---

## 🧪 Testing Checklist

### Test 1: Single Device Notification ✅
- [ ] Get FCM token from app
- [ ] Send test message from Firebase Console
- [ ] Verify notification appears in system tray
- [ ] Verify notification appears in app list
- [ ] Tap notification to open app

### Test 2: Topic Notification ✅
- [ ] Send to "all_users" topic
- [ ] Verify all devices receive it
- [ ] Check notification list in app

### Test 3: Notification with Custom Data ✅
- [ ] Add custom data: `type: booking`
- [ ] Send notification
- [ ] Verify correct icon appears in app list
- [ ] Verify data is accessible

### Test 4: Different Notification Types ✅
- [ ] Send booking notification (calendar icon)
- [ ] Send promotion notification (tag icon)
- [ ] Send reminder notification (bell icon)
- [ ] Send update notification (info icon)

### Test 5: App States ✅
- [ ] App in foreground - notification popup
- [ ] App in background - system tray
- [ ] App closed - system tray
- [ ] Tap notification - opens to home

---

## 🚀 Production Deployment Checklist

### Before Going Live:

1. **Backend Integration**:
   - [ ] Set up backend to receive FCM tokens from users
   - [ ] Store tokens in database linked to user IDs
   - [ ] Implement notification sending logic
   - [ ] Handle token refresh/updates
   - [ ] Remove invalid/expired tokens

2. **Notification Strategy**:
   - [ ] Define when to send notifications
   - [ ] Set up automated triggers (booking confirmed, etc.)
   - [ ] Configure notification frequency limits
   - [ ] Implement user preferences (opt-in/opt-out)

3. **Testing**:
   - [ ] Test on multiple devices
   - [ ] Test all notification types
   - [ ] Test with poor network conditions
   - [ ] Test notification tap actions
   - [ ] Test topic subscriptions

4. **Monitoring**:
   - [ ] Set up Firebase Analytics
   - [ ] Monitor delivery rates
   - [ ] Track open rates
   - [ ] Monitor errors and failures

5. **Compliance**:
   - [ ] Add notification preferences in app settings
   - [ ] Allow users to opt-out
   - [ ] Follow platform guidelines (Android, iOS)
   - [ ] Comply with GDPR/privacy laws

---

## 📊 Firebase Console Quick Links

### Your Project Links:
- **Project Overview**: https://console.firebase.google.com/project/afro-ce148
- **Cloud Messaging**: https://console.firebase.google.com/project/afro-ce148/messaging
- **Project Settings**: https://console.firebase.google.com/project/afro-ce148/settings/general
- **Analytics**: https://console.firebase.google.com/project/afro-ce148/analytics
- **Authentication**: https://console.firebase.google.com/project/afro-ce148/authentication

### Google Cloud Console Links:
- **API Dashboard**: https://console.cloud.google.com/apis/dashboard?project=afro-ce148
- **Credentials**: https://console.cloud.google.com/apis/credentials?project=afro-ce148
- **Firebase Cloud Messaging API**: https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=afro-ce148
- **Firebase Installations API**: https://console.cloud.google.com/apis/library/firebaseinstallations.googleapis.com?project=afro-ce148

---

## 🎯 Quick Start: Send Your First Notification NOW!

1. **Run your app**: `flutter run`
2. **Copy FCM token** from console
3. **Go to**: https://console.firebase.google.com/project/afro-ce148/messaging
4. **Click**: "New campaign" → "Firebase Notification messages"
5. **Fill in**:
   - Title: "Hello!"
   - Message: "Your first notification"
6. **Click**: "Next" → "Send test message"
7. **Paste** your FCM token
8. **Click**: "Test"
9. **Check** your device! 🎉

---

## ❓ Troubleshooting

### Issue: Notifications not received
**Solution**:
1. Verify Firebase Cloud Messaging API is enabled
2. Check FCM token is valid (not null)
3. Verify internet connection
4. Check notification permissions are granted
5. Try uninstalling and reinstalling app

### Issue: Notifications received but not in app list
**Solution**:
1. Check `NotificationsListController` is initialized
2. Verify `_addToNotificationsList` is being called
3. Check SharedPreferences permissions
4. Look for errors in console logs

### Issue: FCM token is null
**Solution**:
1. Enable Firebase Installations API
2. Check API key restrictions
3. Verify google-services.json is correct
4. Wait 5 minutes after enabling APIs
5. Try on real device instead of emulator

---

## 🎉 You're All Set!

Everything is configured in Firebase Console. You can now:
- ✅ Send test notifications
- ✅ Send to specific users
- ✅ Send to topics (groups)
- ✅ Monitor notification performance
- ✅ Integrate with your backend

**Start sending notifications now!** 🚀
