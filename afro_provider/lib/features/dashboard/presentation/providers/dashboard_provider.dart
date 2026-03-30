import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';

// Dashboard Data Models
class DashboardStats {
  final double todayRevenue;
  final int todayAppointments;
  final int totalCustomers;
  final int activeServices;
  final List<Map<String, dynamic>> recentAppointments;
  final List<Map<String, dynamic>> revenueTrends;
  final Map<String, dynamic> providerProfile;

  DashboardStats({
    required this.todayRevenue,
    required this.todayAppointments,
    required this.totalCustomers,
    required this.activeServices,
    required this.recentAppointments,
    required this.revenueTrends,
    required this.providerProfile,
  });
}

// Dashboard State
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats? stats;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.stats,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStats? stats,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stats: stats ?? this.stats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          stats == other.stats;

  @override
  int get hashCode => Object.hash(isLoading, error, stats);
}

// Dashboard Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState()) {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    state = const DashboardState(isLoading: true);

    try {
      // Load all dashboard data in parallel
      final results = await Future.wait([
        analyticsApiService.getProviderAnalytics(period: 'today'),
        analyticsApiService.getRevenueTrends(period: 'week'),
        analyticsApiService.getAppointmentStats(period: 'today'),
        providerService.getProfile(),
      ]);

      final todayAnalytics = results[0] as Map<String, dynamic>;
      final revenueTrends = results[1] as List<dynamic>;
      final appointmentStats = results[2] as Map<String, dynamic>;
      final providerProfile = results[3] as Map<String, dynamic>;

      // Get recent appointments (mock data for now, we'll implement this properly)
      final recentAppointments = await _getRecentAppointments();

      final stats = DashboardStats(
        todayRevenue: (todayAnalytics['revenue'] ?? 0).toDouble(),
        todayAppointments: appointmentStats['today'] ?? 0,
        totalCustomers: todayAnalytics['totalCustomers'] ?? 0,
        activeServices: todayAnalytics['activeServices'] ?? 0,
        recentAppointments: recentAppointments,
        revenueTrends: revenueTrends.cast<Map<String, dynamic>>(),
        providerProfile: providerProfile,
      );

      state = DashboardState(isLoading: false, stats: stats);
    } catch (e) {
      state = DashboardState(error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentAppointments() async {
    try {
      // For now, return empty list - we'll implement this when backend supports it
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    await _loadDashboardData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
