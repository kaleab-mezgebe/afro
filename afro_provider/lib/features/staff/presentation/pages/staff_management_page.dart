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
        _StatChip(label: 'Total', value: state.staff.length.toString(),
            color: AppTheme.black),
        const SizedBox(width: 12),
        _StatChip(label: 'Active', value: active.toString(),
            color: Colors.green),
        const SizedBox(width: 12),
        _StatChip(label: 'On Leave', value: onLeave.toString(),
            color: Colors.orange),
        const SizedBox(width: 12),
        _StatChip(label: 'Inactive', value: inactive.toString(),
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
                  child: Ro