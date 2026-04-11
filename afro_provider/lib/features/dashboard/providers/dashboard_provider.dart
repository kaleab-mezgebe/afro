import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';

// Dashboard state
class DashboardState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? analytics;
  final List<dynamic> recentAppointments;
  final String? selectedShopId;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.analytics,
    this.recentAppointments = const [],
    this.selectedShopId,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? analytics,
    List<dynamic>? recentAppointments,
    String? selectedShopId,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      analytics: analytics ?? this.analytics,
      recentAppointments: recentAppointments ?? this.recentAppointments,
      selectedShopId: selectedShopId ?? this.selectedShopId,
    );
  }
}

// Dashboard provider
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState());

  // Load dashboard data
  Future<void> loadDashboardData(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load analytics from backend API
      final analytics = await analyticsApiService.getShopAnalytics(
        shopId,
        period: 'today',
      );

      // Load recent appointments
      final appointments = await appointmentService.getShopAppointments(
        shopId,
        date: DateTime.now().toIso8601String().split('T')[0],
      );

      state = state.copyWith(
        isLoading: false,
        analytics: analytics,
        recentAppointments: appointments.take(5).toList(),
        selectedShopId: shopId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh dashboard
  Future<void> refresh() async {
    if (state.selectedShopId != null) {
      await loadDashboardData(state.selectedShopId!);
    }
  }
}

// Provider instance
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
