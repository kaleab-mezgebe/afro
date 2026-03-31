import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_provider.dart';
import '../../../../core/models/staff_service_models.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/di/injection_container.dart';

class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() =>
      _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load staff data when page initializes
    Future.microtask(() => ref.read(staffProvider.notifier).loadStaff());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Staff Management',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.black),
            onPressed: () => _showAddStaffDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppTheme.black),
            onPressed: () => _showImportStaffDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.black,
          unselectedLabelColor: AppTheme.greyMedium,
          indicatorColor: AppTheme.primaryYellow,
          tabs: const [
            Tab(text: 'All Staff'),
            Tab(text: 'Active'),
            Tab(text: 'On Leave'),
          ],
        ),
      ),
      body: staffState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilter(),

                // Staff Statistics Cards
                _buildStaffStats(staffState.staff),

                // Staff List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStaffList(staffState.staff, 'All'),
                      _buildStaffList(staffState.staff, 'active'),
                      _buildStaffList(staffState.staff, 'on_leave'),
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
              hintText: 'Search staff by name, email, or phone...',
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
              // Role Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    'All',
                    'barber',
                    'hair_stylist',
                    'makeup_artist',
                    'nail_technician',
                    'receptionist',
                    'manager'
                  ]
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child:
                                Text(role.replaceAll('_', ' ').toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
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
                  items: ['All', 'active', 'inactive', 'on_leave', 'terminated']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child:
                                Text(status.replaceAll('_', ' ').toUpperCase()),
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

  Widget _buildStaffStats(List<Staff> staff) {
    final activeStaff =
        staff.where((s) => s.status == StaffStatus.active).length;
    final onLeaveStaff =
        staff.where((s) => s.status == StaffStatus.onLeave).length;
    final totalStaff = staff.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
                'Total Staff', totalStaff.toString(), AppTheme.primaryYellow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                _buildStatCard('Active', activeStaff.toString(), Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                'On Leave', onLeaveStaff.toString(), Colors.orange),
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

  Widget _buildStaffList(List<Staff> staff, String filterStatus) {
    // Apply filters
    List<Staff> filteredStaff = staff;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filteredStaff = filteredStaff
          .where((s) =>
              s.firstName.toLowerCase().contains(searchQuery) ||
              s.lastName.toLowerCase().contains(searchQuery) ||
              (s.email?.toLowerCase().contains(searchQuery) ?? false) ||
              (s.phoneNumber?.toLowerCase().contains(searchQuery) ?? false))
          .toList();
    }

    // Role filter
    if (_selectedRole != 'All') {
      filteredStaff =
          filteredStaff.where((s) => s.role.value == _selectedRole).toList();
    }

    // Status filter
    if (_selectedStatus != 'All') {
      filteredStaff = filteredStaff
          .where((s) => s.status.value == _selectedStatus)
          .toList();
    }

    // Tab filter
    if (filterStatus != 'All') {
      filteredStaff =
          filteredStaff.where((s) => s.status.value == filterStatus).toList();
    }

    if (filteredStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'No staff members found',
              style: TextStyle(
                color: AppTheme.greyMedium,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or add new staff',
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
        ref.read(staffProvider.notifier).loadStaff();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredStaff.length,
        itemBuilder: (context, index) {
          final staffMember = filteredStaff[index];
          return _StaffCard(
            staff: staffMember,
            onEdit: () => _showEditStaffDialog(staffMember),
            onDelete: () => _showDeleteConfirmDialog(staffMember),
            onToggleStatus: () => _toggleStaffStatus(staffMember),
          );
        },
      ),
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => _StaffDialog(
        onSave: (staffData) async {
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

            // Create staff via API
            final response = await staffService.createStaff(shopId, {
              ...staffData,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Convert to Staff model and add to state
            final newStaff = Staff(
              id: response['id'].toString(),
              shopId: shopId,
              firstName: staffData['firstName'],
              lastName: staffData['lastName'],
              email: staffData['email'],
              phoneNumber: staffData['phoneNumber'],
              role: _parseRole(staffData['role']),
              status: StaffStatus.active,
              experience: staffData['experience'] ?? 0,
              rating: 0.0,
              totalReviews: 0,
              baseSalary: (staffData['baseSalary'] ?? 0).toDouble(),
              canAcceptOnlineBookings:
                  staffData['canAcceptOnlineBookings'] ?? true,
              isFeatured: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            ref.read(staffProvider.notifier).addStaff(newStaff);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Staff member added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding staff: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditStaffDialog(Staff staffMember) {
    showDialog(
      context: context,
      builder: (context) => _StaffDialog(
        staff: staffMember,
        onSave: (staffData) async {
          try {
            // Update staff via API
            await staffService.updateStaff(staffMember.id, {
              ...staffData,
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Update local state
            final updatedStaff = Staff(
              id: staffMember.id,
              shopId: staffMember.shopId,
              firstName: staffData['firstName'],
              lastName: staffData['lastName'],
              email: staffData['email'],
              phoneNumber: staffData['phoneNumber'],
              role: _parseRole(staffData['role']),
              status: staffMember.status,
              experience: staffData['experience'] ?? staffMember.experience,
              rating: staffMember.rating,
              totalReviews: staffMember.totalReviews,
              baseSalary: (staffData['baseSalary'] ?? staffMember.baseSalary)
                  .toDouble(),
              canAcceptOnlineBookings: staffData['canAcceptOnlineBookings'] ??
                  staffMember.canAcceptOnlineBookings,
              isFeatured: staffMember.isFeatured,
              createdAt: staffMember.createdAt,
              updatedAt: DateTime.now(),
            );

            ref.read(staffProvider.notifier).updateStaff(updatedStaff);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Staff member updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating staff: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(Staff staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: Text(
          'Are you sure you want to delete ${staffMember.firstName} ${staffMember.lastName}? This action cannot be undone.',
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
                await staffService.deleteStaff(staffMember.id);
                ref.read(staffProvider.notifier).deleteStaff(staffMember.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Staff member deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting staff: $e')),
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

  void _toggleStaffStatus(Staff staffMember) async {
    try {
      final newStatus = staffMember.status == StaffStatus.active
          ? StaffStatus.inactive
          : StaffStatus.active;

      await staffService.updateStaff(staffMember.id, {
        'status': newStatus.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final updatedStaff = Staff(
        id: staffMember.id,
        shopId: staffMember.shopId,
        firstName: staffMember.firstName,
        lastName: staffMember.lastName,
        email: staffMember.email,
        phoneNumber: staffMember.phoneNumber,
        role: staffMember.role,
        status: newStatus,
        experience: staffMember.experience,
        rating: staffMember.rating,
        totalReviews: staffMember.totalReviews,
        baseSalary: staffMember.baseSalary,
        canAcceptOnlineBookings: staffMember.canAcceptOnlineBookings,
        isFeatured: staffMember.isFeatured,
        createdAt: staffMember.createdAt,
        updatedAt: DateTime.now(),
      );

      ref.read(staffProvider.notifier).updateStaff(updatedStaff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Staff status changed to ${newStatus.value}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating staff status: $e')),
        );
      }
    }
  }

  void _showImportStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Staff'),
        content: const Text(
            'Import functionality will be available soon. You can currently add staff members individually.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  StaffRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'barber':
        return StaffRole.barber;
      case 'hair_stylist':
        return StaffRole.hairStylist;
      case 'makeup_artist':
        return StaffRole.makeupArtist;
      case 'nail_technician':
        return StaffRole.nailTechnician;
      case 'receptionist':
        return StaffRole.receptionist;
      case 'manager':
        return StaffRole.manager;
      case 'owner':
        return StaffRole.owner;
      default:
        return StaffRole.barber;
    }
  }
}

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _StaffCard({
    required this.staff,
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
                // Profile Image or Initial
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${staff.firstName[0]}${staff.lastName[0]}',
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Staff Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${staff.firstName} ${staff.lastName}',
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
                              staff.role.value
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
                              color: _getStatusColor(staff.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              staff.status.value
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(staff.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rating
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          staff.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '(${staff.totalReviews} reviews)',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Contact Info
            if (staff.email != null || staff.phoneNumber != null)
              Row(
                children: [
                  if (staff.email != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.email,
                              size: 16, color: AppTheme.greyMedium),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              staff.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.greyMedium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (staff.phoneNumber != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.phone,
                              size: 16, color: AppTheme.greyMedium),
                          const SizedBox(width: 4),
                          Text(
                            staff.phoneNumber!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyMedium,
                            ),
                          ),
                        ],
                      ),
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
                    staff.status == StaffStatus.active
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(
                    staff.status == StaffStatus.active
                        ? 'Deactivate'
                        : 'Activate',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: staff.status == StaffStatus.active
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

  Color _getStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.active:
        return Colors.green;
      case StaffStatus.inactive:
        return Colors.grey;
      case StaffStatus.onLeave:
        return Colors.orange;
      case StaffStatus.terminated:
        return Colors.red;
    }
  }
}

class _StaffDialog extends StatefulWidget {
  final Staff? staff;
  final Function(Map<String, dynamic>) onSave;

  const _StaffDialog({
    this.staff,
    required this.onSave,
  });

  @override
  State<_StaffDialog> createState() => _StaffDialogState();
}

class _StaffDialogState extends State<_StaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedRole = 'barber';
  bool _canAcceptOnlineBookings = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      _firstNameController.text = widget.staff!.firstName;
      _lastNameController.text = widget.staff!.lastName;
      _emailController.text = widget.staff!.email ?? '';
      _phoneController.text = widget.staff!.phoneNumber ?? '';
      _experienceController.text = widget.staff!.experience.toString();
      _salaryController.text = widget.staff!.baseSalary.toString();
      _selectedRole = widget.staff!.role.value;
      _canAcceptOnlineBookings = widget.staff!.canAcceptOnlineBookings;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
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
              widget.staff == null ? 'Add Staff Member' : 'Edit Staff Member',
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'barber', child: Text('Barber')),
                      DropdownMenuItem(
                          value: 'hair_stylist', child: Text('Hair Stylist')),
                      DropdownMenuItem(
                          value: 'makeup_artist', child: Text('Makeup Artist')),
                      DropdownMenuItem(
                          value: 'nail_technician',
                          child: Text('Nail Technician')),
                      DropdownMenuItem(
                          value: 'receptionist', child: Text('Receptionist')),
                      DropdownMenuItem(
                          value: 'manager', child: Text('Manager')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          decoration: const InputDecoration(
                            labelText: 'Experience (years)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final years = int.tryParse(value);
                              if (years == null || years < 0) {
                                return 'Please enter valid years';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _salaryController,
                          decoration: const InputDecoration(
                            labelText: 'Base Salary',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final salary = double.tryParse(value);
                              if (salary == null || salary < 0) {
                                return 'Please enter valid salary';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _canAcceptOnlineBookings,
                    onChanged: (value) {
                      setState(() {
                        _canAcceptOnlineBookings = value ?? false;
                      });
                    },
                    title: const Text('Can accept online bookings'),
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
                  onPressed: _isLoading ? null : _saveStaff,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.staff == null ? 'Add Staff' : 'Update Staff'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final staffData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'role': _selectedRole,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'baseSalary': double.tryParse(_salaryController.text) ?? 0.0,
        'canAcceptOnlineBookings': _canAcceptOnlineBookings,
      };

      await widget.onSave(staffData);

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
