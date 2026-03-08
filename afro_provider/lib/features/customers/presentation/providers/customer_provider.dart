import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/entities/customer.dart';

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
    state = const CustomerState(isLoading: true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      final mockCustomers = [
        Customer(
          id: '1',
          email: 'john.smith@email.com',
          firstName: 'John',
          lastName: 'Smith',
          phoneNumber: '+1 234-567-8900',
          totalVisits: 12,
          totalSpent: 450.0,
          lastVisit: DateTime.now().subtract(const Duration(days: 7)),
          status: CustomerStatus.active,
        ),
        Customer(
          id: '2',
          email: 'mike.wilson@email.com',
          firstName: 'Mike',
          lastName: 'Wilson',
          phoneNumber: '+1 234-567-8901',
          totalVisits: 8,
          totalSpent: 320.0,
          lastVisit: DateTime.now().subtract(const Duration(days: 14)),
          status: CustomerStatus.active,
        ),
        Customer(
          id: '3',
          email: 'emily.davis@email.com',
          firstName: 'Emily',
          lastName: 'Davis',
          phoneNumber: '+1 234-567-8902',
          totalVisits: 15,
          totalSpent: 680.0,
          lastVisit: DateTime.now().subtract(const Duration(days: 3)),
          status: CustomerStatus.active,
        ),
      ];

      state = CustomerState(
        isLoading: false,
        customers: mockCustomers,
      );
    } catch (e) {
      state = CustomerState(error: e.toString());
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
