import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/modern_cards.dart';
import '../../../../core/models/provider_models.dart';

class ModernServiceManagementPage extends ConsumerStatefulWidget {
  const ModernServiceManagementPage({super.key});

  @override
  ConsumerState<ModernServiceManagementPage> createState() => _ModernServiceManagementPageState();
}

class _ModernServiceManagementPageState extends ConsumerState<ModernServiceManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _searchSlideAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Haircut', 'Beard', 'Coloring', 'Treatment', 'Styling'];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: ModernAnimations.medium,
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: ModernAnimations.bounceCurve,
    ));

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: ModernAnimations.smoothCurve,
    ));

    Future.microtask(() => _fabAnimationController.forward());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Mock services data
  List<Map<String, dynamic>> get _mockServices => [
    {
      'id': '1',
      'name': 'Classic Haircut',
      'category': 'Haircut',
      'price': 25.0,
      'duration': 30,
      'description': 'Professional haircut with styling',
      'isActive': true,
      'rating': 4.8,
      'bookings': 156,
    },
    {
      'id': '2',
      'name': 'Beard Trim',
      'category': 'Beard',
      'price': 15.0,
      'duration': 20,
      'description': 'Precision beard trimming and shaping',
      'isActive': true,
      'rating': 4.9,
      'bookings': 89,
    },
    {
      'id': '3',
      'name': 'Hair Coloring',
      'category': 'Coloring',
      'price': 80.0,
      'duration': 120,
      'description': 'Full hair coloring service',
      'isActive': true,
      'rating': 4.7,
      'bookings': 45,
    },
    {
      'id': '4',
      'name': 'Deep Conditioning',
      'category': 'Treatment',
      'price': 35.0,
      'duration': 45,
      'description:': 'Intensive hair treatment',
      'isActive': false,
      'rating': 4.6,
      'bookings': 23,
    },
    {
      'id': '5',
      'name:': 'Wedding Styling',
      'category': 'Styling',
      'price': 150.0,
      'duration': 180,
      'description': 'Special occasion hair styling',
      'isActive': true,
      'rating': 5.0,
      'bookings': 12,
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    var services = _mockServices;
    if (_selectedCategory != 'All') {
      services = services.where((service) => service['category'] == _selectedCategory).toList();
    }
    if (_searchController.text.isNotEmpty) {
      services = services.where((service) =>
          service['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    return services;
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _filteredServices;

    return Scaffold(
      backgroundColor: ModernTheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Search
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: ModernTheme.surface,
            elevation: 0,
            expandedHeight: _isSearchExpanded ? 140 : 80,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedSwitcher(
                duration: ModernAnimations.fast,
                child: Text(
                  _isSearchExpanded ? '' : 'Services',
                  key: ValueKey(_isSearchExpanded),
                  style: ModernTheme.headlineMedium,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: ModernTheme.secondaryGradient,
                      ),
                    ),
                  ),
                  if (_isSearchExpanded)
                    Container(
                      height: 60,
                      color: ModernTheme.surface,
                    ),
                ],
              ),
            ),
            actions: [
              AnimatedBuilder(
                animation: _searchSlideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _searchSlideAnimation,
                    child: IconButton(
                      icon: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        color: ModernTheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                        });
                        if (_isSearchExpanded) {
                          _searchAnimationController.forward();
                        } else {
                          _searchAnimationController.reverse();
                          _searchController.clear();
                        }
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Bar
          if (_isSearchExpanded)
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _searchSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModernSearchBar(
                    controller: _searchController,
                    hintText: 'Search services...',
                    onClear: () => _searchController.clear(),
                  ),
                ),
              ),
            ),

          // Category Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: ModernTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ModernChip(
                            label: category,
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = category);
                              }
                            },
                            selectedColor: ModernTheme.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ModernStatCard(
                      title: 'Total Services',
                      value: _mockServices.length.toString(),
                      icon: Icons.content_cut,
                      iconColor: ModernTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernStatCard(
                      title: 'Active',
                      value: _mockServices
                          .where((service) => service['isActive'])
                          .length
                          .toString(),
                      icon: Icons.check_circle,
                      iconColor: ModernTheme.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Services List
          if (filteredServices.isEmpty)
            SliverToBoxAdapter(
              child: ModernEmptyState(
                title: 'No Services Found',
                subtitle: _isSearchExpanded || _selectedCategory != 'All'
                    ? 'Try adjusting your filters'
                    : 'Create your first service',
                icon: Icons.content_cut,
                action: ModernActionButton(
                  label: 'Add Service',
                  icon: Icons.add,
                  onPressed: () => _showCreateServiceDialog(context),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = filteredServices[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildModernServiceCard(service),
                  );
                },
                childCount: filteredServices.length,
              ),
            ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Modern FAB
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: ModernFab(
          icon: Icons.add,
          onPressed: () => _showCreateServiceDialog(context),
          tooltip: 'Add Service',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernServiceCard(Map<String, dynamic> service) {
    return ModernGlassCard(
      onTap: () => _showServiceDetails(context, service),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Status
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: ModernTheme.secondaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.content_cut,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: ModernTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ModernChip(
                      label: service['category'],
                      selected: service['isActive'],
                      backgroundColor: ModernTheme.surfaceVariant,
                      selectedColor: service['isActive']
                          ? ModernTheme.success
                          : ModernTheme.warning,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: ModernTheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditServiceDialog(context, service);
                      break;
                    case 'toggle_status':
                      _toggleServiceStatus(service);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, service);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Service'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          service['isActive'] ? Icons.block : Icons.check_circle,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(service['isActive'] ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: ModernTheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Delete Service',
                          style: TextStyle(color: ModernTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            service['description'],
            style: ModernTheme.bodyMedium.copyWith(
              color: ModernTheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                'Price',
                '\$${service['price']}',
                Icons.monetization_on,
                ModernTheme.success,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Duration',
                '${service['duration']}min',
                Icons.access_time,
                ModernTheme.info,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Rating',
                service['rating'].toString(),
                Icons.star,
                ModernTheme.warning,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Bookings',
                service['bookings'].toString(),
                Icons.book_online,
                ModernTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: ModernTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: ModernTheme.labelMedium.copyWith(
            color: ModernTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: ModernTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ModernTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: ModernTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  ModernStatCard(
                    title: 'Category',
                    value: service['category'],
                    icon: Icons.category,
                    iconColor: ModernTheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ModernActionButton(
                          label: 'Edit',
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditServiceDialog(context, service);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernActionButton(
                          label: 'View Bookings',
                          icon: Icons.calendar_today,
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bookings feature coming soon'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Haircut';
    bool isActive = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: ModernTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREATE NEW SERVICE',
                style: ModernTheme.labelMedium.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g. Classic Haircut',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g. 25.00',
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g. 30',
                  suffixText: 'min',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the service...',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CATEGORY',
                style: ModernTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Haircut', 'Beard', 'Coloring', 'Treatment', 'Styling'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ModernChip(
                    label: cat,
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedCategory = cat);
                      }
                    },
                    selectedColor: ModernTheme.secondary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Active',
                    style: ModernTheme.titleMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: isActive,
                    onChanged: (value) => setModalState(() => isActive = value),
                    activeColor: ModernTheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ModernActionButton(
                  label: 'Create Service',
                  icon: Icons.add,
                  isFullWidth: true,
                  onPressed: () {
                    if (nameController.text.isNotEmpty && 
                        priceController.text.isNotEmpty && 
                        durationController.text.isNotEmpty) {
                      // Create service logic here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Service created successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, Map<String, dynamic> service) {
    // Similar to create dialog but with pre-filled data
    _showCreateServiceDialog(context);
  }

  void _toggleServiceStatus(Map<String, dynamic> service) {
    // Toggle service status logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service ${service['isActive'] ? 'deactivated' : 'activated'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: ModernTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
