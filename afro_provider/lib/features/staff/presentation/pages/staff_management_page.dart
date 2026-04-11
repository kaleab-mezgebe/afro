import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../../../../core/models/staff_service_models.dart';
import '../../../../core/utils/app_theme.dart';

class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() =>
      _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(staffProvider.notifier).loadStaff());
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('STAFF MANAGEMENT'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showAddStaffSheet(context),
          ),
        ],
      ),
      body: staffState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : staffState.error != null
              ? _buildErrorState(staffState.error!)
              : RefreshIndicator(
                  onRefresh: () => ref.read(staffProvider.notifier).loadStaff(),
                  color: AppTheme.primaryYellow,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(staffState),
                        const SizedBox(height: 24),
                        if (staffState.staff.isEmpty)
                          _buildEmptyState()
                        else ...[
                          const Text(
                            'TEAM MEMBERS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppTheme.greyMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...staffState.staff
                              .map((s) => _buildStaffCard(s))
                              .toList(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffSheet(context),
        backgroundColor: AppTheme.primaryYellow,
        child: const Icon(Icons.person_add_rounded, color: AppTheme.black),
      ),
    );
  }

  Widget _buildStatsRow(StaffState state) {
    final active =
        state.staff.where((s) => s.status == StaffStatus.active).length;
    final onLeave =
        state.staff.where((s) => s.status == StaffStatus.onLeave).length;
    final inactive =
        state.staff.where((s) => s.status == StaffStatus.inactive).length;

    return Row(
      children: [
        _StatChip(
            label: 'Total',
            value: state.staff.length.toString(),
            color: AppTheme.black),
        const SizedBox(width: 12),
        _StatChip(
            label: 'Active', value: active.toString(), color: Colors.green),
        const SizedBox(width: 12),
        _StatChip(
            label: 'On Leave', value: onLeave.toString(), color: Colors.orange),
        const SizedBox(width: 12),
        _StatChip(
            label: 'Inactive',
            value: inactive.toString(),
            color: AppTheme.greyMedium),
      ],
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getRoleColor(staff.role).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${staff.firstName[0]}${staff.lastName[0]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _getRoleColor(staff.role),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${staff.firstName} ${staff.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getRoleColor(staff.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          staff.role.value.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getRoleColor(staff.role),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusDot(status: staff.status),
                    ],
                  ),
                  if (staff.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      staff.email!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.greyMedium),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.greyMedium),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditStaffSheet(context, staff);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, staff);
                    break;
                  case 'toggle':
                    _toggleStaffStatus(staff);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(Icons.power_settings_new, size: 16),
                    SizedBox(width: 8),
                    Text('Toggle Status'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: AppTheme.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(staffProvider.notifier).loadStaff(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: AppTheme.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No staff members yet',
            style: TextStyle(fontSize: 16, color: AppTheme.greyMedium),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first team member to get started',
            style: TextStyle(fontSize: 12, color: AppTheme.greyMedium),
          ),
        ],
      ),
    );
  }

  void _showAddStaffSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADD STAFF MEMBER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
              SizedBox(height: 16),
              Text('Add staff form will be implemented here'),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditStaffSheet(BuildContext context, Staff staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EDIT STAFF MEMBER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              Text('Editing: ${staff.firstName} ${staff.lastName}'),
              const SizedBox(height: 16),
              const Text('Edit staff form will be implemented here'),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: Text(
          'Are you sure you want to delete ${staff.firstName} ${staff.lastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(staffProvider.notifier).deleteStaff(staff.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleStaffStatus(Staff staff) {
    final newStatus = staff.status == StaffStatus.active
        ? StaffStatus.inactive
        : StaffStatus.active;
    ref.read(staffProvider.notifier).updateStaffStatus(staff.id, newStatus);
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.barber:
        return Colors.blue;
      case StaffRole.hairStylist:
        return Colors.purple;
      case StaffRole.receptionist:
        return Colors.orange;
      case StaffRole.manager:
        return Colors.green;
      case StaffRole.makeupArtist:
        return Colors.pink;
      case StaffRole.nailTechnician:
        return Colors.teal;
      case StaffRole.owner:
        return Colors.amber;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final StaffStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case StaffStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case StaffStatus.onLeave:
        color = Colors.orange;
        label = 'On Leave';
        break;
      case StaffStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case StaffStatus.terminated:
        color = Colors.red;
        label = 'Terminated';
        break;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
