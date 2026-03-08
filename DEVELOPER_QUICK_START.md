# Developer Quick Start Guide

## 🚀 Customer App - New Features & Best Practices

### Table of Contents
1. [API Caching](#api-caching)
2. [Connectivity Monitoring](#connectivity-monitoring)
3. [Reusable Widgets](#reusable-widgets)
4. [Error Handling](#error-handling)
5. [Search Optimization](#search-optimization)

---

## API Caching

### When to Use
- GET requests for data that doesn't change frequently
- List views (barbers, services, appointments)
- Profile information
- Static content

### How to Use

```dart
// In your API service
Future<Response> getBarbers() async {
  return await _apiClient.get(
    '/barbers',
    useCache: true,                          // Enable caching
    cacheDuration: Duration(minutes: 10),    // Cache for 10 minutes
  );
}

// Clear cache when data changes
_apiClient.clearCacheEntry('/barbers');

// Clear all cache
_apiClient.clearCache();
```

### Cache Duration Guidelines
- Static data (services, categories): 30 minutes
- User profiles: 10 minutes
- Search results: 5 minutes
- Real-time data (appointments): Don't cache

---

## Connectivity Monitoring

### Setup (Already Done)
```dart
// In InitialBindingEnhanced
Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
```

### Usage in Controllers

```dart
class MyController extends GetxController {
  final ConnectivityService _connectivity = Get.find();
  
  Future<void> loadData() async {
    // Check before API call
    if (!_connectivity.isOnline.value) {
      Get.snackbar('Offline', 'Please check your internet connection');
      return;
    }
    
    // Make API call
    try {
      final data = await apiService.getData();
    } catch (e) {
      // Handle error
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    
    // Listen to connectivity changes
    _connectivity.isOnline.listen((isOnline) {
      if (isOnline) {
        // Reload data when back online
        loadData();
      }
    });
  }
}
```

### Check Connection Type
```dart
if (_connectivity.isWifi) {
  // Download large files
} else if (_connectivity.isMobile) {
  // Show data usage warning
}
```

---

## Reusable Widgets

### AppCard

Replace custom cards with AppCard for consistency:

```dart
// Before
Card(
  child: InkWell(
    onTap: () => navigate(),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: MyContent(),
    ),
  ),
)

// After
AppCard(
  onTap: () => navigate(),
  semanticLabel: 'Provider card',
  child: MyContent(),
)
```

### AppButton

Use AppButton for all buttons:

```dart
// Primary button
AppButton(
  text: 'Book Now',
  type: AppButtonType.primary,
  onPressed: () => book(),
)

// Secondary button
AppButton(
  text: 'Cancel',
  type: AppButtonType.secondary,
  onPressed: () => cancel(),
)

// Outlined button
AppButton(
  text: 'Learn More',
  type: AppButtonType.outlined,
  onPressed: () => showInfo(),
)

// Text button
AppButton(
  text: 'Skip',
  type: AppButtonType.text,
  onPressed: () => skip(),
)

// With icon
AppButton(
  text: 'Book Now',
  icon: Icons.calendar_today,
  onPressed: () => book(),
)

// Loading state
AppButton(
  text: 'Booking...',
  isLoading: isBooking.value,
  onPressed: () => book(),
)
```

### AppLoading

```dart
// Full screen loading
AppLoading(
  message: 'Loading providers...',
)

// Small inline loading
AppLoadingSmall()
```

### AppEmptyState

```dart
AppEmptyState(
  icon: Icons.search_off,
  title: 'No Results Found',
  message: 'Try adjusting your search filters',
  actionText: 'Clear Filters',
  onAction: () => clearFilters(),
)
```

---

## Error Handling

### Basic Error Handling

```dart
try {
  final result = await apiService.getData();
  // Handle success
} catch (e) {
  final message = ErrorHandler.getErrorMessage(e);
  ErrorHandler.showErrorSnackbar(message);
}
```

### With Retry Button

```dart
try {
  final result = await apiService.getData();
} catch (e) {
  ErrorHandler.showErrorSnackbar(
    ErrorHandler.getErrorMessage(e),
    onRetry: () => loadData(),  // Retry function
  );
}
```

### Automatic Retry with Exponential Backoff

```dart
try {
  final result = await ErrorHandler.withRetry(
    () => apiService.getData(),
    maxRetries: 3,
    retryDelay: Duration(seconds: 2),
    exponentialBackoff: true,
  );
} catch (e) {
  // All retries failed
  ErrorHandler.showErrorSnackbar(ErrorHandler.getErrorMessage(e));
}
```

### Check Error Type

```dart
catch (e) {
  if (ErrorHandler.isNetworkError(e)) {
    // Show offline message
  } else if (ErrorHandler.isAuthError(e)) {
    // Redirect to login
  } else {
    // Show generic error
  }
}
```

---

## Search Optimization

### Debouncing (Already Implemented)

The search controller now automatically debounces search input with a 500ms delay.

```dart
// In your search UI
TextField(
  onChanged: (value) => controller.updateQuery(value),
  // Automatically debounced - no extra code needed!
)
```

### Manual Search Trigger

```dart
// For search button
ElevatedButton(
  onPressed: () => controller.performSearch(),
  child: Text('Search'),
)
```

---

## Best Practices

### 1. Always Check Connectivity for Critical Operations

```dart
Future<void> bookAppointment() async {
  if (!Get.find<ConnectivityService>().isOnline.value) {
    Get.snackbar('Offline', 'Cannot book appointment while offline');
    return;
  }
  
  // Proceed with booking
}
```

### 2. Use Caching for List Views

```dart
Future<void> loadBarbers() async {
  final response = await _apiClient.get(
    '/barbers',
    useCache: true,
    cacheDuration: Duration(minutes: 10),
  );
}
```

### 3. Clear Cache After Mutations

```dart
Future<void> updateProfile() async {
  await apiService.updateProfile(data);
  
  // Clear profile cache
  _apiClient.clearCacheEntry('/profile');
}
```

### 4. Use Reusable Widgets

```dart
// Good
AppButton(text: 'Submit', onPressed: submit)

// Avoid
ElevatedButton(
  style: ElevatedButton.styleFrom(...),
  child: Text('Submit'),
  onPressed: submit,
)
```

### 5. Handle Errors Gracefully

```dart
// Good
try {
  await operation();
} catch (e) {
  ErrorHandler.showErrorSnackbar(
    ErrorHandler.getErrorMessage(e),
    onRetry: () => operation(),
  );
}

// Avoid
try {
  await operation();
} catch (e) {
  print(e); // No user feedback
}
```

### 6. Add Semantic Labels

```dart
// Good
AppCard(
  semanticLabel: 'Provider ${provider.name}',
  child: ProviderInfo(provider),
)

// Avoid
Card(child: ProviderInfo(provider))
```

---

## Common Patterns

### Loading State Pattern

```dart
class MyController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Item> items = <Item>[].obs;
  
  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final response = await apiService.getItems();
      items.assignAll(response);
    } catch (e) {
      ErrorHandler.showErrorSnackbar(
        ErrorHandler.getErrorMessage(e),
        onRetry: () => loadItems(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// In UI
Obx(() {
  if (controller.isLoading.value) {
    return AppLoading(message: 'Loading items...');
  }
  
  if (controller.items.isEmpty) {
    return AppEmptyState(
      icon: Icons.inbox,
      title: 'No Items',
      message: 'No items found',
    );
  }
  
  return ListView.builder(...);
})
```

### Refresh Pattern

```dart
RefreshIndicator(
  onRefresh: () async {
    // Clear cache before refresh
    _apiClient.clearCacheEntry('/items');
    await controller.loadItems();
  },
  child: ListView(...),
)
```

### Offline-First Pattern

```dart
Future<List<Item>> getItems() async {
  // Try cache first
  final cached = _cacheService.get<List<Item>>('items');
  if (cached != null) {
    return cached;
  }
  
  // Check connectivity
  if (!_connectivity.isOnline.value) {
    throw Exception('No internet connection');
  }
  
  // Fetch from API
  final response = await _apiClient.get('/items');
  final items = parseItems(response.data);
  
  // Cache for offline use
  _cacheService.set('items', items, duration: Duration(hours: 1));
  
  return items;
}
```

---

## Testing Tips

### Test with Connectivity Changes

```dart
// Simulate offline
Get.find<ConnectivityService>().isOnline.value = false;

// Test your UI
expect(find.text('Offline'), findsOneWidget);

// Simulate online
Get.find<ConnectivityService>().isOnline.value = true;
```

### Test Cache Behavior

```dart
// First call - should hit API
await service.getItems();

// Second call - should use cache
await service.getItems();

// Verify cache was used
verify(mockApiClient.get(any, useCache: true)).called(1);
```

---

## Troubleshooting

### Cache Not Working
- Check if `useCache: true` is set
- Verify cache duration is not too short
- Check if cache was cleared

### Connectivity Not Detected
- Ensure ConnectivityService is initialized in bindings
- Check if device has proper network permissions
- Test on real device (emulator may have issues)

### Debouncing Not Working
- Verify you're using `updateQuery()` method
- Check if timer is being cancelled properly
- Ensure controller is not being recreated

---

## Quick Reference

### Import Statements

```dart
// Services
import 'package:customer_app/core/services/cache_service.dart';
import 'package:customer_app/core/services/connectivity_service.dart';
import 'package:customer_app/core/services/enhanced_api_client.dart';

// Widgets
import 'package:customer_app/core/widgets/app_card.dart';
import 'package:customer_app/core/widgets/app_button.dart';
import 'package:customer_app/core/widgets/app_loading.dart';
import 'package:customer_app/core/widgets/app_empty_state.dart';

// Utils
import 'package:customer_app/core/utils/error_handler.dart';
```

### Get Services

```dart
final connectivity = Get.find<ConnectivityService>();
final apiClient = Get.find<EnhancedApiClient>();
final cache = CacheService(); // Singleton
```

---

## Need Help?

- Check `CUSTOMER_APP_IMPROVEMENTS_COMPLETE.md` for detailed documentation
- Review `CUSTOMER_APP_ACTION_ITEMS.md` for remaining tasks
- See existing implementations in API services for examples

---

**Last Updated**: March 8, 2026  
**Version**: 1.0.0
