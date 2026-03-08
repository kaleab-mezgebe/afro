import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dashboard State
class DashboardState {
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(isLoading, error);
}

// Dashboard Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> refresh() async {
    state = const DashboardState(isLoading: true);

    try {
      // TODO: Implement actual API call to fetch dashboard data
      await Future.delayed(const Duration(seconds: 2));

      state = const DashboardState(isLoading: false);
    } catch (e) {
      state = DashboardState(error: e.toString());
    }
  }

  void clearError() {
    state = const DashboardState(error: null);
  }
}

// Providers
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
