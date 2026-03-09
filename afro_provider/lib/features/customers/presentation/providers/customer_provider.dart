import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/entities/customer.dart';
import '../../../../core/di/injection_container.dart';

// Customer State
class CustomerState {
  final bool isLoading;
  final String? error;
  final List<Customer> customers;

  const CustomerState({
    this.isLoading = false,
    this.error,
    this.customers = const [],
  });

  CustomerState copyWith({
    bool? isLoading,
    String? error,
    List<Customer>? customers,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      customers: customers ?? this.customers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          customers == other.customers;

  @override
  int get hashCode => Object.hash(isLoading, error, customers);
}

// Customer Notifier
class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier() : super(const CustomerState());

  Future<void> loadCustomers() async {
    try {
      state = const CustomerState(isLoading: true);

      // Get shop ID from provider service (assuming first shop)
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        state = const CustomerState(
          isLoading: false,
          error: 'No shop found. Please create a shop first.',
          customers: [],
        );
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch customers from API
      final response = await customerService.getShopCustomers(shopId);

      // Convert API response to Customer models
      final customers = response.map((json) {
        return Customer(
          id: json['id'].toString(),
          email: json['email'] ?? '',
          firstName: json['firstName'] ?? '',
          lastName: json['lastName'] ?? '',
          phoneNumber: json['phoneNumber'] ?? '',
          totalVisits: json['totalVisits'] ?? 0,
          totalSpent: (json['totalSpent'] ?? 0).toDouble(),
          lastVisit: json['lastVisit'] != null
              ? DateTime.parse(json['lastVisit'])
              : DateTime.now(),
          status: _parseStatus(json['status']),
        );
      }).toList();

      state = CustomerState(
        isLoading: false,
        customers: customers,
        error: null,
      );
    } catch (e) {
      state = CustomerState(
        isLoading: false,
        error: 'Failed to load customers: ${e.toString()}',
      );
    }
  }

  CustomerStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return CustomerStatus.active;
      case 'inactive':
        return CustomerStatus.inactive;
      case 'blocked':
      case 'suspended':
        return CustomerStatus.suspended;
      case 'vip':
        return CustomerStatus.vip;
      default:
        return CustomerStatus.active;
    }
  }

  void addCustomer(Customer customer) {
    final currentCustomers = List<Customer>.from(state.customers);
    currentCustomers.add(customer);
    state = state.copyWith(customers: currentCustomers);
  }

  void updateCustomer(Customer customer) {
    final currentCustomers = List<Customer>.from(state.customers);
    final index = currentCustomers.indexWhere((c) => c.id == customer.id);

    if (index != -1) {
      currentCustomers[index] = customer;
    }

    state = state.copyWith(customers: currentCustomers);
  }

  void deleteCustomer(String customerId) {
    final currentCustomers =
        state.customers.where((customer) => customer.id != customerId).toList();
    state = state.copyWith(customers: currentCustomers);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(),
);
