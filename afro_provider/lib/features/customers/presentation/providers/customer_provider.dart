import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/entities/customer.dart';
import '../../../../core/di/injection_container.dart';

// Customer State
class CustomerState {
  final bool isLoading;
  final String? error;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final bool isAddingCustomer;
  final bool isEditingCustomer;

  const CustomerState({
    this.isLoading = false,
    this.error,
    this.customers = const [],
    this.selectedCustomer,
    this.isAddingCustomer = false,
    this.isEditingCustomer = false,
  });

  CustomerState copyWith({
    bool? isLoading,
    String? error,
    List<Customer>? customers,
    Customer? selectedCustomer,
    bool? isAddingCustomer,
    bool? isEditingCustomer,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      isAddingCustomer: isAddingCustomer ?? this.isAddingCustomer,
      isEditingCustomer: isEditingCustomer ?? this.isEditingCustomer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          customers == other.customers &&
          selectedCustomer == other.selectedCustomer &&
          isAddingCustomer == other.isAddingCustomer &&
          isEditingCustomer == other.isEditingCustomer;

  @override
  int get hashCode => Object.hash(isLoading, error, customers, selectedCustomer,
      isAddingCustomer, isEditingCustomer);
}

// Customer Notifier
class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier() : super(const CustomerState()) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    state = const CustomerState(isLoading: true);

    try {
      // Get provider profile to get shop ID
      final providerProfile = await providerService.getProfile();

      // For now, we'll use a mock shop ID since we don't have shops setup yet
      // In a real implementation, you'd get the shop ID from provider profile
      const shopId = 'default-shop';

      // Fetch customers from API
      final response = await customerService.getShopCustomers(shopId);

      // Handle different response formats
      List<dynamic> customersData;
      if (response is Map<String, dynamic>) {
        final data = response as Map<String, dynamic>;
        if (data['customers'] != null && data['customers'] is List) {
          customersData = data['customers'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          customersData = data['data'] as List<dynamic>;
        } else {
          customersData = [];
        }
      } else if (response is List) {
        customersData = response as List<dynamic>;
      } else {
        customersData = [];
      }

      // Convert API response to Customer models
      final customers = customersData.map((json) {
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

  Future<void> addCustomer(Customer customer) async {
    state = state.copyWith(isAddingCustomer: true, error: null);

    try {
      // Get provider profile to get shop ID
      final providerProfile = await providerService.getProfile();
      const shopId = 'default-shop';

      // Convert customer to API format
      final customerData = {
        'firstName': customer.firstName,
        'lastName': customer.lastName,
        'email': customer.email,
        'phoneNumber': customer.phoneNumber,
        'shopId': shopId,
      };

      // Create customer via API (this endpoint might need to be created)
      // For now, we'll simulate adding to the local list
      final newCustomer = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: customer.firstName,
        lastName: customer.lastName,
        email: customer.email,
        phoneNumber: customer.phoneNumber,
        totalVisits: 0,
        totalSpent: 0.0,
        lastVisit: DateTime.now(),
        status: CustomerStatus.active,
      );

      final updatedCustomers = [...state.customers, newCustomer];

      state = state.copyWith(
        isAddingCustomer: false,
        customers: updatedCustomers,
      );
    } catch (e) {
      state = state.copyWith(
        isAddingCustomer: false,
        error: 'Failed to add customer: ${e.toString()}',
      );
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    state = state.copyWith(isEditingCustomer: true, error: null);

    try {
      // Get provider profile to get shop ID
      final providerProfile = await providerService.getProfile();
      const shopId = 'default-shop';

      // Convert customer to API format
      final customerData = {
        'firstName': customer.firstName,
        'lastName': customer.lastName,
        'email': customer.email,
        'phoneNumber': customer.phoneNumber,
        'shopId': shopId,
      };

      // Update customer via API (this endpoint might need to be created)
      // For now, we'll simulate updating the local list
      final updatedCustomers = state.customers.map((c) {
        return c.id == customer.id ? customer : c;
      }).toList();

      state = state.copyWith(
        isEditingCustomer: false,
        customers: updatedCustomers,
        selectedCustomer: null,
      );
    } catch (e) {
      state = state.copyWith(
        isEditingCustomer: false,
        error: 'Failed to update customer: ${e.toString()}',
      );
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // Delete customer via API (this endpoint might need to be created)
      // For now, we'll simulate removing from the local list
      final updatedCustomers = state.customers
          .where((customer) => customer.id != customerId)
          .toList();

      state = state.copyWith(
        customers: updatedCustomers,
        selectedCustomer: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete customer: ${e.toString()}',
      );
    }
  }

  Future<void> toggleCustomerStatus(String customerId) async {
    try {
      // Find customer and toggle status
      final customer = state.customers.firstWhere((c) => c.id == customerId);
      final newStatus = customer.status == CustomerStatus.active
          ? CustomerStatus.inactive
          : CustomerStatus.active;

      await updateCustomer(customer.copyWith(status: newStatus));
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to toggle customer status: ${e.toString()}',
      );
    }
  }

  void selectCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }
}

// Providers
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(),
);
