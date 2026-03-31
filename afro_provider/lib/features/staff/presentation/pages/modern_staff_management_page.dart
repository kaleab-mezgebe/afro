import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/modern_cards.dart';

// Staff model
class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String specialty;
  final double rating;
  final int completedServices;
  final bool isActive;
  final DateTime joinDate;
  final String? avatar;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.specialty,
    required this.rating,
    required this.completedServices,
    required this.isActive,
    required this.joinDate,
    this.avatar,
  });
}

class ModernStaffManagementPage extends ConsumerStatefulWidget {
  const ModernStaffManagementPage({super.key});

  @override
  ConsumerState<ModernStaffManagementPage> createState() =>
      _ModernStaffManagementPageState();
}

class _ModernStaffManagementPageState
    extends ConsumerState<ModernStaffManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _searchSlideAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _selectedRole = 'All';
  final List<String> _roles = [
    'All',
    'Barber',
    'Stylist',
    'Beard Specialist',
    'Colorist',
    'Manager'
  ];

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

  // Mock staff data
  List<Staff> get _mockStaff => [
        Staff(
          id: '1',
          name: 'John Smith',
          email: 'john@afrocuts.com',
          phone: '+1234567890',
          role: 'Barber',
          specialty: 'Classic Cuts',
          rating: 4.8,
          completedServices: 156,
          isActive: true,
          joinDate: DateTime.now().subtract(const Duration(days: 365)),
        ),
        Staff(
          id: '2',
          name: 'Sarah Johnson',
          email: 'sarah@afrocuts.com',
          phone: '+1234567891',
          role: 'Stylist',
          specialty: 'Modern Styles',
          rating: 4.9,
          completedServices: 203,
          isActive: true,
          joinDate: DateTime.now().subtract(const Duration(days: 280)),
        ),
        Staff(
          id: '3',
          name: 'Mike Wilson',
          email: 'mike@afrocuts.com',
          phone: '+1234567892',
          role: 'Beard Specialist',
          specialty: 'Beard Art',
          rating: 4.7,
          completedServices: 89,
          isActive: true,
          joinDate: DateTime.now().subtract(const Duration(days: 180)),
        ),
        Staff(
          id: '4',
          name: 'Emily Brown',
          email: 'emily@afrocuts.com',
          phone: '+1234567893',
          role: 'Colorist',
          specialty: 'Hair Coloring',
          rating: 5.0,
          completedServices: 67,
          isActive: false,
          joinDate: DateTime.now().subtract(const Duration(days: 120)),
        ),
        Staff(
          id: '5',
          name: 'David Lee',
          email: 'david@afrocuts.com',
          phone: '+1234567894',
          role: 'Manager',
          specialty: 'Shop Management',
          rating: 4.6,
          completedServices: 0,
          isActive: true,
          joinDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ];

  List<Staff> get _filteredStaff {
    var staff = _mockStaff;
    if (_selectedRole != 'All') {
      staff = staff.where((member) => member.role == _selectedRole).toList();
    }
    if (_searchController.text.isNotEmpty) {
      staff = staff
          .where((member) =>
              member.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              member.email
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }
    return staff;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _filteredStaff;

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
                  _isSearchExpanded ? '' : 'Staff',
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
                        colors: [
                          ModernTheme.info,
                          ModernTheme.primary,
                        ],
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
                    hintText: 'Search staff...',
                    onClear: () => _searchController.clear(),
                  ),
                ),
              ),
            ),

          // Role Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles',
                    style: ModernTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _roles.length,
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = role == _selectedRole;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ModernChip(
                            label: role,
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRole = role);
                              }
                            },
                            selectedColor: ModernTheme.info,
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
                      title: 'Total Staff',
                      value: _mockStaff.length.toString(),
                      icon: Icons.people,
                      iconColor: ModernTheme.info,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernStatCard(
                      title: 'Active',
                      value: _mockStaff
                          .where((member) => member.isActive)
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

          // Staff List
          if (filteredStaff.isEmpty)
            SliverToBoxAdapter(
              child: ModernEmptyState(
                title: 'No Staff Found',
                subtitle: _isSearchExpanded || _selectedRole != 'All'
                    ? 'Try adjusting your filters'
                    : 'Add your first staff member',
                icon: Icons.people,
                action: ModernActionButton(
                  label: 'Add Staff',
                  icon: Icons.person_add,
                  onPressed: () => _showCreateStaffDialog(context),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final staff = filteredStaff[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildModernStaffCard(staff),
                  );
                },
                childCount: filteredStaff.length,
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
          icon: Icons.person_add,
          onPressed: () => _showCreateStaffDialog(context),
          tooltip: 'Add Staff',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernStaffCard(Staff staff) {
    return ModernGlassCard(
      onTap: () => _showStaffDetails(context, staff),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar and Status
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ModernTheme.info, ModernTheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
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
                      staff.name,
                      style: ModernTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ModernChip(
                      label: staff.role,
                      selected: staff.isActive,
                      backgroundColor: ModernTheme.surfaceVariant,
                      selectedColor: staff.isActive
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
                      _showEditStaffDialog(context, staff);
                      break;
                    case 'toggle_status':
                      _toggleStaffStatus(staff);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, staff);
                      break;
                    case 'schedule':
                      _showStaffSchedule(context, staff);
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
                        Text('Edit Staff'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          staff.isActive ? Icons.block : Icons.check_circle,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(staff.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 12),
                        Text('Schedule'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete,
                            size: 20, color: ModernTheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Delete Staff',
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

          // Contact Info
          Row(
            children: [
              Icon(Icons.email, size: 16, color: ModernTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  staff.email,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 16, color: ModernTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                staff.phone,
                style: ModernTheme.bodyMedium.copyWith(
                  color: ModernTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Specialty
          Row(
            children: [
              Icon(Icons.work, size: 16, color: ModernTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Specialty: ${staff.specialty}',
                style: ModernTheme.bodyMedium.copyWith(
                  color: ModernTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                'Rating',
                staff.rating.toString(),
                Icons.star,
                ModernTheme.warning,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Services',
                staff.completedServices.toString(),
                Icons.content_cut,
                ModernTheme.primary,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Joined',
                '${DateTime.now().difference(staff.joinDate).inDays}d',
                Icons.calendar_today,
                ModernTheme.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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

  void _showStaffDetails(BuildContext context, Staff staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    staff.name,
                    style: ModernTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ModernStatCard(
                        title: 'Role',
                        value: staff.role,
                        icon: Icons.work,
                        iconColor: ModernTheme.info,
                      ),
                      const SizedBox(width: 16),
                      ModernStatCard(
                        title: 'Specialty',
                        value: staff.specialty,
                        icon: Icons.star,
                        iconColor: ModernTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ModernStatCard(
                    title: 'Contact',
                    value: '${staff.email}\n${staff.phone}',
                    icon: Icons.contact_phone,
                    iconColor: ModernTheme.primary,
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
                            _showEditStaffDialog(context, staff);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernActionButton(
                          label: 'Schedule',
                          icon: Icons.schedule,
                          onPressed: () {
                            Navigator.pop(context);
                            _showStaffSchedule(context, staff);
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

  void _showCreateStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final specialtyController = TextEditingController();
    String selectedRole = 'Barber';
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
                'ADD NEW STAFF',
                style: ModernTheme.labelMedium.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. John Smith',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'e.g. john@afrocuts.com',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'e.g. +1234567890',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  hintText: 'e.g. Classic Cuts',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ROLE',
                style: ModernTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Barber',
                  'Stylist',
                  'Beard Specialist',
                  'Colorist',
                  'Manager'
                ].map((role) {
                  final isSelected = selectedRole == role;
                  return ModernChip(
                    label: role,
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedRole = role);
                      }
                    },
                    selectedColor: ModernTheme.info,
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
                    activeColor: ModernTheme.info,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ModernActionButton(
                  label: 'Add Staff',
                  icon: Icons.person_add,
                  isFullWidth: true,
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      // Add staff logic here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Staff member added successfully'),
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

  void _showEditStaffDialog(BuildContext context, Staff staff) {
    // Similar to create dialog but with pre-filled data
    _showCreateStaffDialog(context);
  }

  void _toggleStaffStatus(Staff staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Staff ${staff.isActive ? 'deactivated' : 'activated'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to remove "${staff.name}"?'),
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
                  content: Text('Staff member removed'),
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

  void _showStaffSchedule(BuildContext context, Staff staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule for ${staff.name} coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
