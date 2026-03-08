# Customer App - Action Items Checklist

## 🚨 Priority 1: Critical (Do First)

### Accessibility Fixes
- [ ] Add `Semantics` widgets to all interactive elements
- [ ] Add `tooltip` property to all `IconButton` widgets
- [ ] Add `label` property to all `TextField` widgets
- [ ] Test with TalkBack (Android) and VoiceOver (iOS)
- [ ] Fix color contrast issues (ensure 4.5:1 ratio minimum)
- [ ] Add `ExcludeSemantics` where appropriate
- [ ] Verify all images have semantic labels

**Estimated Time**: 2-3 days  
**Impact**: High - Makes app accessible to all users

### Error Message Improvements
- [ ] Implement specific error handling for different DioException types
- [ ] Add user-friendly messages for network errors
- [ ] Add retry mechanisms for failed requests
- [ ] Implement exponential backoff for retries
- [ ] Add offline detection and messaging

**Estimated Time**: 1 day  
**Impact**: High - Better user experience

---

## ⚠️ Priority 2: Important (Do Soon)

### Testing Implementation
- [ ] Set up test environment
- [ ] Write unit tests for all API services (8 services)
- [ ] Write unit tests for all controllers
- [ ] Write widget tests for key screens (10+ screens)
- [ ] Write integration tests for critical flows
- [ ] Set up CI/CD with automated testing
- [ ] Aim for 70%+ code coverage

**Estimated Time**: 1-2 weeks  
**Impact**: High - Prevents regressions

### API Response Caching
- [ ] Install `flutter_cache_manager` package
- [ ] Create `CacheService` class
- [ ] Implement caching in `EnhancedApiClient`
- [ ] Add cache invalidation logic
- [ ] Cache images with `CachedNetworkImage`
- [ ] Add cache size limits
- [ ] Implement cache clearing functionality

**Estimated Time**: 3-4 days  
**Impact**: Medium - Improves performance

### Code Refactoring
- [ ] Extract common UI widgets to `lib/core/widgets/`
- [ ] Create `AppCard` widget for repeated card patterns
- [ ] Create `AppButton` widget for consistent buttons
- [ ] Extract common styles to theme
- [ ] Remove code duplication in controllers
- [ ] Consolidate similar methods

**Estimated Time**: 2-3 days  
**Impact**: Medium - Easier maintenance

---

## 💡 Priority 3: Nice to Have (Future)

### Documentation
- [ ] Add doc comments to all public methods
- [ ] Create developer onboarding guide
- [ ] Document architecture decisions
- [ ] Create testing guide
- [ ] Document deployment process
- [ ] Add inline comments for complex logic
- [ ] Create API integration examples

**Estimated Time**: 1-2 days  
**Impact**: Medium - Easier onboarding

### Offline Support
- [ ] Install `connectivity_plus` package
- [ ] Create `ConnectivityService`
- [ ] Implement offline detection
- [ ] Add offline indicators in UI
- [ ] Cache data for offline access
- [ ] Queue actions for when online
- [ ] Sync data when connection restored

**Estimated Time**: 1 week  
**Impact**: Medium - Better UX

### Analytics & Monitoring
- [ ] Install `firebase_analytics` package
- [ ] Install `firebase_crashlytics` package
- [ ] Create `AnalyticsService`
- [ ] Log screen views
- [ ] Log user actions
- [ ] Track conversion funnels
- [ ] Set up crash reporting
- [ ] Add performance monitoring

**Estimated Time**: 2-3 days  
**Impact**: Medium - Better insights

### Performance Optimization
- [ ] Implement image compression before upload
- [ ] Add progressive image loading
- [ ] Optimize bundle size
- [ ] Implement code splitting
- [ ] Add request batching
- [ ] Optimize animations
- [ ] Profile and fix memory leaks

**Estimated Time**: 1 week  
**Impact**: Low-Medium - Marginal improvements

---

## 🎯 Quick Wins (Can Do Today)

### 30-Minute Tasks
- [ ] Add tooltips to all IconButtons
- [ ] Fix obvious color contrast issues
- [ ] Add loading timeouts to API calls
- [ ] Update error messages to be more user-friendly
- [ ] Add missing const constructors

### 1-Hour Tasks
- [ ] Implement search debouncing
- [ ] Add pull-to-refresh on list screens
- [ ] Create reusable loading widget
- [ ] Add empty state illustrations
- [ ] Implement haptic feedback on actions

### 2-Hour Tasks
- [ ] Create comprehensive error handling utility
- [ ] Implement retry logic for failed requests
- [ ] Add network connectivity indicator
- [ ] Create reusable dialog widgets
- [ ] Add app version display in settings

---

## 📋 Detailed Task Breakdown

### Task 1: Add Accessibility Labels

**Files to Update**:
- `lib/features/home/views/home_page.dart`
- `lib/features/search/views/search_page.dart`
- `lib/features/favorites/views/favorites_page.dart`
- `lib/features/appointments/views/*.dart`
- `lib/features/profile/views/*.dart`

**Example**:
```dart
// Before
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: () => controller.toggleFavorite(),
)

// After
Semantics(
  label: 'Add to favorites',
  button: true,
  child: IconButton(
    icon: Icon(Icons.favorite),
    tooltip: 'Add to favorites',
    onPressed: () => controller.toggleFavorite(),
  ),
)
```

---

### Task 2: Implement Unit Tests

**Files to Create**:
- `test/services/appointment_api_service_test.dart`
- `test/services/barber_api_service_test.dart`
- `test/services/payment_api_service_test.dart`
- `test/controllers/phone_auth_controller_test.dart`
- `test/controllers/appointments_controller_test.dart`

**Example**:
```dart
// test/services/appointment_api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AppointmentApiService', () {
    late AppointmentApiService service;
    late MockEnhancedApiClient mockClient;

    setUp(() {
      mockClient = MockEnhancedApiClient();
      service = AppointmentApiService(mockClient);
    });

    test('createAppointment returns success', () async {
      // Arrange
      when(mockClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: {'id': '123', 'status': 'confirmed'},
                statusCode: 200,
              ));

      // Act
      final result = await service.createAppointment(
        barberId: 'barber-1',
        serviceId: 'service-1',
        appointmentDate: DateTime.now(),
      );

      // Assert
      expect(result['id'], '123');
      expect(result['status'], 'confirmed');
    });

    test('createAppointment throws on error', () async {
      // Arrange
      when(mockClient.post(any, data: anyNamed('data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/appointments'),
            type: DioExceptionType.connectionError,
          ));

      // Act & Assert
      expect(
        () => service.createAppointment(
          barberId: 'barber-1',
          serviceId: 'service-1',
          appointmentDate: DateTime.now(),
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

---

### Task 3: Implement Caching

**Files to Create**:
- `lib/core/services/cache_service.dart`

**Files to Update**:
- `lib/core/services/enhanced_api_client.dart`
- `lib/core/bindings/initial_binding_enhanced.dart`

**Example**:
```dart
// lib/core/services/cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final _memoryCache = <String, CacheEntry>{};
  final _cacheManager = DefaultCacheManager();

  // Memory cache for API responses
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null || entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  void set<T>(String key, T data, {Duration duration = const Duration(minutes: 5)}) {
    _memoryCache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration),
    );
  }

  void clear() {
    _memoryCache.clear();
  }

  // File cache for images
  Future<File> getFile(String url) async {
    return await _cacheManager.getSingleFile(url);
  }

  Future<void> clearImageCache() async {
    await _cacheManager.emptyCache();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

---

### Task 4: Add Offline Support

**Files to Create**:
- `lib/core/services/connectivity_service.dart`

**Example**:
```dart
// lib/core/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = isOnline.value;
    isOnline.value = result != ConnectivityResult.none;

    if (!isOnline.value && wasOnline) {
      Get.snackbar(
        'Offline',
        'You are currently offline',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } else if (isOnline.value && !wasOnline) {
      Get.snackbar(
        'Online',
        'Connection restored',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }
}
```

---

## 📊 Progress Tracking

### Week 1 Goals
- [ ] Complete all Priority 1 tasks
- [ ] Implement 5 quick wins
- [ ] Start unit testing

### Week 2 Goals
- [ ] Complete 50% of unit tests
- [ ] Implement caching
- [ ] Start widget tests

### Week 3 Goals
- [ ] Complete all tests
- [ ] Implement offline support
- [ ] Code refactoring

### Week 4 Goals
- [ ] Add analytics
- [ ] Complete documentation
- [ ] Final testing and QA

---

## ✅ Definition of Done

Each task is considered complete when:
- [ ] Code is written and tested
- [ ] No new compilation errors
- [ ] Tests pass (if applicable)
- [ ] Code is reviewed
- [ ] Documentation is updated
- [ ] Changes are committed

---

**Created**: March 8, 2026  
**Last Updated**: March 8, 2026  
**Status**: Ready for Implementation
