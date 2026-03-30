import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/provider_models.dart';

// Shop Settings State
class ShopSettingsState {
  final bool isLoading;
  final String? error;
  final ShopSettings? settings;
  final WorkingHours? workingHours;
  final SocialMediaLinks? socialMediaLinks;
  final bool notificationsEnabled;

  const ShopSettingsState({
    this.isLoading = false,
    this.error,
    this.settings,
    this.workingHours,
    this.socialMediaLinks,
    this.notificationsEnabled = true,
  });

  ShopSettingsState copyWith({
    bool? isLoading,
    String? error,
    ShopSettings? settings,
    WorkingHours? workingHours,
    SocialMediaLinks? socialMediaLinks,
    bool? notificationsEnabled,
  }) {
    return ShopSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      settings: settings ?? this.settings,
      workingHours: workingHours ?? this.workingHours,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopSettingsState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          settings == other.settings &&
          workingHours == other.workingHours &&
          socialMediaLinks == other.socialMediaLinks &&
          notificationsEnabled == other.notificationsEnabled;

  @override
  int get hashCode => Object.hash(
        isLoading,
        error,
        settings,
        workingHours,
        socialMediaLinks,
        notificationsEnabled,
      );
}

// Shop Settings Notifier
class ShopSettingsNotifier extends StateNotifier<ShopSettingsState> {
  ShopSettingsNotifier() : super(const ShopSettingsState());

  Future<void> loadShopSettings(String shopId) async {
    state = state.copyWith(isLoading: true);

    try {
      // In a real app, this would fetch from API
      // For now, we'll use default settings

      final defaultSettings = ShopSettings(
        allowOnlineBooking: true,
        requireDeposit: false,
        depositAmount: 0.0,
        cancellationPolicy:
            'Free cancellation up to 24 hours before appointment',
        advanceBookingDays: 30,
      );

      final defaultWorkingHours = WorkingHours(
        monday:
            const DaySchedule(open: '9:00 AM', close: '8:00 PM', closed: false),
        tuesday:
            const DaySchedule(open: '9:00 AM', close: '8:00 PM', closed: false),
        wednesday:
            const DaySchedule(open: '9:00 AM', close: '8:00 PM', closed: false),
        thursday:
            const DaySchedule(open: '9:00 AM', close: '8:00 PM', closed: false),
        friday:
            const DaySchedule(open: '9:00 AM', close: '9:00 PM', closed: false),
        saturday: const DaySchedule(
            open: '8:00 AM', close: '10:00 PM', closed: false),
        sunday: const DaySchedule(
            open: '10:00 AM', close: '6:00 PM', closed: false),
      );

      final defaultSocialMedia = SocialMediaLinks(
        facebook: null,
        instagram: null,
        twitter: null,
        youtube: null,
      );

      state = ShopSettingsState(
        isLoading: false,
        settings: defaultSettings,
        workingHours: defaultWorkingHours,
        socialMediaLinks: defaultSocialMedia,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateShopSettings(ShopSettings settings) async {
    try {
      state = state.copyWith(isLoading: true);

      // In a real app, this would update the API
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call

      state = state.copyWith(
        isLoading: false,
        settings: settings,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update settings: ${e.toString()}',
      );
    }
  }

  Future<void> updateWorkingHours(WorkingHours workingHours) async {
    try {
      state = state.copyWith(isLoading: true);

      // In a real app, this would update the API
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call

      state = state.copyWith(
        isLoading: false,
        workingHours: workingHours,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update working hours: ${e.toString()}',
      );
    }
  }

  Future<void> updateSocialMediaLinks(SocialMediaLinks socialMediaLinks) async {
    try {
      state = state.copyWith(isLoading: true);

      // In a real app, this would update the API
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call

      state = state.copyWith(
        isLoading: false,
        socialMediaLinks: socialMediaLinks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update social media links: ${e.toString()}',
      );
    }
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    // In a real app, this would update the API
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final shopSettingsProvider =
    StateNotifierProvider<ShopSettingsNotifier, ShopSettingsState>(
  (ref) => ShopSettingsNotifier(),
);
