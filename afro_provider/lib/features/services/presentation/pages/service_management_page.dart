import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/staff_service_models.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/di/injection_container.dart';

class ServiceManagementPage extends ConsumerStatefulWidget {
  const ServiceManagementPage({super.key});

  @override
  ConsumerState<ServiceManagementPage> createState() =>
      _ServiceManagementPageState();
}

class _ServiceManagementPageState extends ConsumerState<ServiceManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load services data when page initializes
    Future.microtask(() => _loadServices());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      // Get shop ID
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No shop found. Please create a shop first.')),
          );
        }
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch services from API
      final response = await serviceService.getShopServices(shopId);

      // Convert API response to Service models
      final services = response.map((json) {
        return Service(
          id: json['id'].toString(),
          shopId: shopId,
          name: json['name'] ?? '',
          category: _parseCategory(json['category']),
          description: json['description'],
          basePrice: (json['basePrice'] ?? 0).toDouble(),
          duration: json['duration'] ?? 30,
          status: _parseStatus(json['status']),
          isVariantBased: json['isVariantBased'] ?? false,
          variants: [], // TODO: Parse variants if needed
          addOns: [], // TODO: Parse add-ons if needed
          dynamicPricing: [], // TODO: Parse dynamic pricing if needed
          popularityScore: json['popularityScore'] ?? 0,
          totalBookings: json['totalBookings'] ?? 0,
          averageRating: (json['averageRating'] ?? 0).toDouble(),
          totalReviews: json['totalReviews'] ?? 0,
          staffIds: [], // TODO: Parse staff IDs if needed
          createdAt: DateTime.parse(
              json['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(
              json['updatedAt'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      // Update state (you'll need to create a services provider)
      // For now, just store in local variable
      _services = services;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  List<Service> _services = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Service Management',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.black),
            onPressed: () => _showAddServiceDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload, color: AppTheme.black),
            onPressed: () => _showImportServicesDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.black,
          unselectedLabelColor: AppTheme.greyMedium,
          indicatorColor: AppTheme.primaryYellow,
          tabs: const [
            Tab(text: 'All Services'),
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),

          // Service Statistics
          _buildServiceStats(),

          // Services List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesList('All'),
                _buildServicesList('active'),
                _buildServicesList('inactive'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search services by name or description...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.greyLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryYellow),
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild for search
            },
          ),
          const SizedBox(height: 16),

          // Filter Row
          Row(
            children: [
              // Category Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    'All',
                    'haircut',
                    'beard_trim',
                    'hair_coloring',
                    'hair_styling',
                    'makeup',
                    'nail_care',
                    'skin_care',
                    'waxing',
                    'facial',
                    'other'
                  ]
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                                category.replaceAll('_', ' ').toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['All', 'active', 'inactive', 'seasonal']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStats() {
    final activeServices =
        _services.where((s) => s.status == ServiceStatus.active).length;
    final inactiveServices =
        _services.where((s) => s.status == ServiceStatus.inactive).length;
    final totalServices = _services.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Services', totalServices.toString(),
                AppTheme.primaryYellow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                'Active', activeServices.toString(), Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                'Inactive', inactiveServices.toString(), Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(String filterStatus) {
    // Apply filters
    List<Service> filteredServices = _services;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filteredServices = filteredServices
          .where((s) =>
              s.name.toLowerCase().contains(searchQuery) ||
              (s.description?.toLowerCase().contains(searchQuery) ?? false))
          .toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      filteredServices = filteredServices
          .where((s) => s.category.value == _selectedCategory)
          .toList();
    }

    // Status filter
    if (_selectedStatus != 'All') {
      filteredServices = filteredServices
          .where((s) => s.status.value == _selectedStatus)
          .toList();
    }

    // Tab filter
    if (filterStatus != 'All') {
      filteredServices = filteredServices
          .where((s) => s.status.value == filterStatus)
          .toList();
    }

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.content_cut_outlined,
              size: 64,
              color: AppTheme.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(
                color: AppTheme.greyMedium,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or add new services',
              style: TextStyle(
                color: AppTheme.greyMedium,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadServices();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          return _ServiceCard(
            service: service,
            onEdit: () => _showEditServiceDialog(service),
            onDelete: () => _showDeleteConfirmDialog(service),
            onToggleStatus: () => _toggleServiceStatus(service),
          );
        },
      ),
    );
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        onSave: (serviceData) async {
          try {
            // Get shop ID
            final shops = await shopService.getShops();
            if (shops.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('No shop found. Please create a shop first.')),
              );
              return;
            }

            final shopId = shops[0]['id'].toString();

            // Create service via API
            final response = await serviceService.createService(shopId, {
              ...serviceData,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Convert to Service model and add to list
            final newService = Service(
              id: response['id'].toString(),
              shopId: shopId,
              name: serviceData['name'],
              category: _parseCategory(serviceData['category']),
              description: serviceData['description'],
              basePrice: (serviceData['basePrice'] ?? 0).toDouble(),
              duration: serviceData['duration'] ?? 30,
              status: ServiceStatus.active,
              isVariantBased: serviceData['isVariantBased'] ?? false,
              variants: [],
              addOns: [],
              dynamicPricing: [],
              popularityScore: 0,
              totalBookings: 0,
              averageRating: 0.0,
              totalReviews: 0,
              staffIds: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            _services.add(newService);
            setState(() {});

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding service: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditServiceDialog(Service service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        service: service,
        onSave: (serviceData) async {
          try {
            // Update service via API
            await serviceService.updateService(service.id, {
              ...serviceData,
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Update local state
            final updatedService = Service(
              id: service.id,
              shopId: service.shopId,
              name: serviceData['name'],
              category: _parseCategory(serviceData['category']),
              description: serviceData['description'],
              basePrice:
                  (serviceData['basePrice'] ?? service.basePrice).toDouble(),
              duration: serviceData['duration'] ?? service.duration,
              status: service.status,
              isVariantBased:
                  serviceData['isVariantBased'] ?? service.isVariantBased,
              variants: service.variants,
              addOns: service.addOns,
              dynamicPricing: service.dynamicPricing,
              popularityScore: service.popularityScore,
              totalBookings: service.totalBookings,
              averageRating: service.averageRating,
              totalReviews: service.totalReviews,
              staffIds: service.staffIds,
              createdAt: service.createdAt,
              updatedAt: DateTime.now(),
            );

            final index = _services.indexWhere((s) => s.id == service.id);
            if (index != -1) {
              _services[index] = updatedService;
              setState(() {});
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating service: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete ${service.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await serviceService.deleteService(service.id);
                _services.removeWhere((s) => s.id == service.id);
                setState(() {});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Service deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting service: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleServiceStatus(Service service) async {
    try {
      final newStatus = service.status == ServiceStatus.active
          ? ServiceStatus.inactive
          : ServiceStatus.active;

      await serviceService.updateService(service.id, {
        'status': newStatus.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final updatedService = Service(
        id: service.id,
        shopId: service.shopId,
        name: service.name,
        category: service.category,
        description: service.description,
        basePrice: service.basePrice,
        duration: service.duration,
        status: newStatus,
        isVariantBased: service.isVariantBased,
        variants: service.variants,
        addOns: service.addOns,
        dynamicPricing: service.dynamicPricing,
        popularityScore: service.popularityScore,
        totalBookings: service.totalBookings,
        averageRating: service.averageRating,
        totalReviews: service.totalReviews,
        staffIds: service.staffIds,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = updatedService;
        setState(() {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Service status changed to ${newStatus.value}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating service status: $e')),
        );
      }
    }
  }

  void _showImportServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Services'),
        content: const Text(
            'Import functionality will be available soon. You can currently add services individually.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  ServiceCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'haircut':
        return ServiceCategory.haircut;
      case 'beard_trim':
        return ServiceCategory.beardTrim;
      case 'hair_coloring':
        return ServiceCategory.hairColoring;
      case 'hair_styling':
        return ServiceCategory.hairStyling;
      case 'makeup':
        return ServiceCategory.makeup;
      case 'nail_care':
        return ServiceCategory.nailCare;
      case 'skin_care':
        return ServiceCategory.skinCare;
      case 'waxing':
        return ServiceCategory.waxing;
      case 'facial':
        return ServiceCategory.facial;
      case 'other':
        return ServiceCategory.other;
      default:
        return ServiceCategory.haircut;
    }
  }

  ServiceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'seasonal':
        return ServiceStatus.seasonal;
      default:
        return ServiceStatus.active;
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service Icon or Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: AppTheme.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.category.value
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(service.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.status.value.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(service.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price and Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${service.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    Text(
                      '${service.duration} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            if (service.description != null && service.description!.isNotEmpty)
              Text(
                service.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.greyMedium,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                // Rating
                if (service.totalReviews > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' (${service.totalReviews})',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),

                const Spacer(),

                // Bookings
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AppTheme.greyMedium),
                    const SizedBox(width: 4),
                    Text(
                      '${service.totalBookings} bookings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    service.status == ServiceStatus.active
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(
                    service.status == ServiceStatus.active
                        ? 'Deactivate'
                        : 'Activate',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: service.status == ServiceStatus.active
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.inactive:
        return Colors.grey;
      case ServiceStatus.seasonal:
        return Colors.blue;
    }
  }
}

class _ServiceDialog extends StatefulWidget {
  final Service? service;
  final Function(Map<String, dynamic>) onSave;

  const _ServiceDialog({
    this.service,
    required this.onSave,
  });

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'haircut';
  bool _isVariantBased = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description ?? '';
      _priceController.text = widget.service!.basePrice.toString();
      _durationController.text = widget.service!.duration.toString();
      _selectedCategory = widget.service!.category.value;
      _isVariantBased = widget.service!.isVariantBased;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.service == null ? 'Add Service' : 'Edit Service',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter service name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'haircut', child: Text('Haircut')),
                      DropdownMenuItem(
                          value: 'beard_trim', child: Text('Beard Trim')),
                      DropdownMenuItem(
                          value: 'hair_coloring', child: Text('Hair Coloring')),
                      DropdownMenuItem(
                          value: 'hair_styling', child: Text('Hair Styling')),
                      DropdownMenuItem(value: 'makeup', child: Text('Makeup')),
                      DropdownMenuItem(
                          value: 'nail_care', child: Text('Nail Care')),
                      DropdownMenuItem(
                          value: 'skin_care', child: Text('Skin Care')),
                      DropdownMenuItem(value: 'waxing', child: Text('Waxing')),
                      DropdownMenuItem(value: 'facial', child: Text('Facial')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Base Price (\$) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Please enter valid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration (minutes) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter duration';
                            }
                            final duration = int.tryParse(value);
                            if (duration == null || duration <= 0) {
                              return 'Please enter valid duration';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _isVariantBased,
                    onChanged: (value) {
                      setState(() {
                        _isVariantBased = value ?? false;
                      });
                    },
                    title: const Text(
                        'Service has variants (e.g., different sizes)'),
                    subtitle: const Text(
                        'Enable if this service has multiple options with different prices'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.service == null
                          ? 'Add Service'
                          : 'Update Service'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final serviceData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'basePrice': double.tryParse(_priceController.text) ?? 0.0,
        'duration': int.tryParse(_durationController.text) ?? 30,
        'isVariantBased': _isVariantBased,
      };

      await widget.onSave(serviceData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
