# AFRO Provider App - Backend Integration Complete

## ✅ Integration Status

The afro_provider app is now fully integrated with the NestJS backend running on `http://localhost:3001/api/v1`.

## 🏗️ Architecture Overview

### Backend (NestJS + PostgreSQL)
- **Location**: `/backend`
- **Port**: 3001
- **API Prefix**: `/api/v1`
- **Documentation**: http://localhost:3001/api/docs
- **Authentication**: Firebase Admin SDK + JWT

### Frontend (Flutter + Riverpod)
- **Location**: `/afro_provider`
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Hive + SharedPreferences

## 📦 New Files Created

### Core Configuration
1. `lib/core/config/api_config.dart` - API endpoints and configuration
2. `lib/core/network/api_client.dart` - Dio HTTP client wrapper
3. `lib/core/network/api_interceptor.dart` - Request/response interceptor

### Services Layer
4. `lib/core/services/auth_service.dart` - Authentication with Firebase
5. `lib/core/services/provider_service.dart` - Provider profile management
6. `lib/core/services/shop_service.dart` - Shop CRUD operations
7. `lib/core/services/staff_service.dart` - Staff management
8. `lib/core/services/service_service.dart` - Service management
9. `lib/core/services/appointment_service.dart` - Appointment management
10. `lib/core/services/analytics_service.dart` - Analytics and reporting

### State Management (Riverpod)
11. `lib/features/auth/providers/auth_provider.dart` - Auth state management
12. `lib/features/dashboard/providers/dashboard_provider.dart` - Dashboard state

### Updated Files
13. `lib/core/di/injection_container.dart` - Updated with all services
14. `pubspec.yaml` - Ensured all dependencies are present

## 🔌 API Endpoints Integrated

### Authentication (`/api/v1/auth`)
- ✅ POST `/verify-token` - Verify Firebase token
- ✅ GET `/me` - Get current user info
- ✅ POST `/assign-role` - Assign role (admin only)
- ✅ POST `/refresh` - Refresh user data

### Provider Management (`/api/v1/providers`)
- ✅ POST `/register` - Register new provider
- ✅ GET `/profile` - Get provider profile
- ✅ PUT `/profile` - Update provider profile

### Shop Management (`/api/v1/providers/shops`)
- ✅ POST `/` - Create new shop
- ✅ GET `/` - Get all provider shops
- ✅ PUT `/:shopId` - Update shop
- ✅ DELETE `/:shopId` - Delete shop

### Staff Management (`/api/v1/providers/shops/:shopId/staff`)
- ✅ POST `/` - Add staff member
- ✅ GET `/` - Get shop staff
- ✅ PUT `/:staffId` - Update staff member
- ✅ DELETE `/:staffId` - Delete staff member

### Service Management (`/api/v1/providers/shops/:shopId/services`)
- ✅ POST `/` - Create service
- ✅ GET `/` - Get shop services
- ✅ PUT `/:serviceId` - Update service
- ✅ DELETE `/:serviceId` - Delete service

### Appointment Management (`/api/v1/providers/shops/:shopId/appointments`)
- ✅ GET `/` - Get shop appointments (with date filter)
- ✅ PUT `/:appointmentId/status` - Update appointment status

### Analytics & Reporting (`/api/v1/providers/shops/:shopId`)
- ✅ GET `/analytics` - Get shop analytics (today/week/month/year)
- ✅ GET `/earnings` - Get shop earnings
- ✅ GET `/portfolio` - Get shop portfolio
- ✅ GET `/customers` - Get shop customers (CRM)

## 🚀 Quick Start Guide

### 1. Start the Backend

```bash
cd backend
npm install
npm run start:dev
```

Backend will run on http://localhost:3001

### 2. Configure API URL

Edit `afro_provider/lib/core/config/api_config.dart`:

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:3001/api/v1';

// For iOS simulator
static const String baseUrl = 'http://localhost:3001/api/v1';

// For physical device (replace with your IP)
static const String baseUrl = 'http://192.168.1.100:3001/api/v1';
```

### 3. Install Dependencies

```bash
cd afro_provider
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## 📱 Usage Examples

### Authentication

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:afro_provider/features/auth/providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return ElevatedButton(
      onPressed: () async {
        await authNotifier.signInWithEmailPassword(
          'provider@example.com',
          'password123',
        );
      },
      child: Text('Sign In'),
    );
  }
}
```

### Dashboard Data

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:afro_provider/features/dashboard/providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    // Load dashboard data
    useEffect(() {
      dashboardNotifier.loadDashboardData('shop-id-123');
      return null;
    }, []);

    if (dashboardState.isLoading) {
      return CircularProgressIndicator();
    }

    final analytics = dashboardState.analytics;
    return Column(
      children: [
        Text('Revenue: \$${analytics?['totalRevenue']}'),
        Text('Bookings: ${analytics?['totalBookings']}'),
      ],
    );
  }
}
```

### Direct Service Usage

```dart
import 'package:afro_provider/core/di/injection_container.dart';

// Get shops
final shops = await shopService.getShops();

// Create shop
final newShop = await shopService.createShop({
  'name': 'My Barber Shop',
  'category': 'barber_shop',
  'address': '123 Main St',
  'phoneNumber': '+1234567890',
});

// Get appointments
final appointments = await appointmentService.getShopAppointments(
  'shop-id-123',
  date: '2026-03-08',
);

// Update appointment status
await appointmentService.updateAppointmentStatus(
  'appointment-id-456',
  'confirmed',
  notes: 'Customer confirmed via phone',
);

// Get analytics
final analytics = await analyticsService.getShopAnalytics(
  'shop-id-123',
  period: 'month',
);
```

## 🔐 Authentication Flow

1. User signs in with Firebase (email/password or Google)
2. Firebase returns ID token
3. App sends token to backend `/auth/verify-token`
4. Backend verifies token with Firebase Admin SDK
5. Backend creates/updates user in database
6. Backend assigns default CUSTOMER role (or BARBER for providers)
7. App stores token and sets it in API client headers
8. All subsequent requests include `Authorization: Bearer <token>`

## 🎯 Features Ready to Use

### ✅ Fully Integrated
1. **Authentication** - Sign in, sign up, sign out, password reset
2. **Provider Profile** - Get and update provider information
3. **Shop Management** - CRUD operations for shops
4. **Staff Management** - Add, update, delete staff members
5. **Service Management** - Manage services and pricing
6. **Appointment Management** - View and update appointments
7. **Analytics** - Real-time business metrics

### ⚠️ Backend Ready, UI Needs Update
1. **Dashboard** - Connect existing UI to analytics API
2. **Appointments Page** - Connect to appointment API
3. **Services Page** - Connect to service management API
4. **Staff Page** - Connect to staff management API
5. **Analytics Page** - Connect to analytics API

### ❌ Coming Soon (Backend Endpoints Exist)
1. **Portfolio Management** - Photo gallery and reviews
2. **CRM** - Customer relationship management
3. **Earnings Tracking** - Financial reporting
4. **Multi-branch Support** - Manage multiple locations

## 🔧 Configuration

### Environment Variables

Create `.env` file in backend:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_NAME=afro_db

FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----..."
```

### Firebase Setup

1. Create Firebase project
2. Enable Authentication (Email/Password, Google)
3. Download `google-services.json` (Android)
4. Download `GoogleService-Info.plist` (iOS)
5. Add Firebase config to app

## 📊 Database Schema

The backend uses PostgreSQL with TypeORM. Key entities:

- **users** - Base user information
- **user_roles** - Role assignments (admin, barber, customer)
- **providers** - Provider profiles
- **shops** - Shop information
- **staff** - Staff members
- **services** - Service offerings
- **appointments** - Appointment bookings
- **reviews** - Customer reviews
- **favorites** - User favorites

## 🐛 Troubleshooting

### Connection Refused
- Check backend is running on port 3001
- Update API URL in `api_config.dart` for your device
- Check firewall settings

### Authentication Errors
- Verify Firebase configuration
- Check Firebase token is valid
- Ensure backend has correct Firebase credentials

### CORS Errors
- Backend already configured for CORS
- Check allowed origins in `backend/src/main.ts`

### Data Not Loading
- Check network logs in Dio interceptor
- Verify API endpoints match backend routes
- Check authentication token is set

## 📚 API Documentation

Full API documentation available at:
http://localhost:3001/api/docs

Swagger UI provides:
- All available endpoints
- Request/response schemas
- Try-it-out functionality
- Authentication requirements

## 🎉 Next Steps

1. **Update Dashboard UI** - Connect to analytics API
2. **Implement Appointments Page** - Show real appointment data
3. **Add Service Management** - Full CRUD interface
4. **Staff Management UI** - Add, edit, delete staff
5. **Portfolio Feature** - Photo upload and gallery
6. **CRM Integration** - Customer management interface
7. **Earnings Dashboard** - Financial reporting
8. **Real-time Updates** - WebSocket integration
9. **Push Notifications** - Firebase Cloud Messaging
10. **Offline Support** - Local caching with Hive

## 🔗 Related Documentation

- [Backend Multi-Role Setup](../backend/MULTI_ROLE_SETUP.md)
- [Database Schema](../backend/database.sql)
- [API Endpoints](http://localhost:3001/api/docs)
- [Firebase Setup](./FIREBASE_SETUP.md)

---

**Status**: ✅ Backend Integration Complete
**Date**: March 8, 2026
**Version**: 1.0.0
