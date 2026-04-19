import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/modern_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_loading.dart';
import '../../../../core/widgets/modern_navigation.dart';
import '../../../../core/widgets/modern_search.dart';
import '../../../../core/widgets/modern_states.dart';
import '../../../../core/widgets/modern_responsive.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  bool _isLoading = false;

  // Search and filter state
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _sortBy = 'date';

  // Error handling state
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Get shop ID
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No shop found. Please create a shop first.';
        });
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch appointments for the month
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final response = await appointmentService.getShopAppointments(
        shopId,
        startDate: DateFormat('yyyy-MM-dd').format(startOfMonth),
        endDate: DateFormat('yyyy-MM-dd').format(endOfMonth),
      );

      // Group appointments by date
      final Map<DateTime, List<Map<String, dynamic>>> groupedAppointments = {};

      for (final appointment in response) {
        final dateStr =
            appointment['date'] ?? appointment['startTime']?.split(' ')[0];
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final dayKey = DateTime(date.year, date.month, date.day);

          if (!groupedAppointments.containsKey(dayKey)) {
            groupedAppointments[dayKey] = [];
          }
          groupedAppointments[dayKey]!.add(appointment);
        }
      }

      setState(() {
        _appointments = groupedAppointments;
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading appointments: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: ModernAppBar(
        title: 'Appointments',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom +
                  (ResponsiveBreakpoints.isMobile(context) ? 60 : 70),
            ),
            child: _buildCalendarView(),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom +
                  (ResponsiveBreakpoints.isMobile(context) ? 60 : 70),
            ),
            child: _buildListView(),
          ),
        ],
      ),
      floatingActionButton: ModernFloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(),
        tooltip: 'Add Appointment',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarView() {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    return Column(
      children: [
        // Calendar
        Expanded(
          flex: isMobile ? 2 : 3,
          child: ModernCard(
            margin: EdgeInsets.all(isMobile ? 8 : 16),
            child: _hasError
                ? ModernErrorState(
                    title: 'Calendar Error',
                    subtitle: _errorMessage,
                    onRetry: _loadAppointments,
                  )
                : TableCalendar<Map<String, dynamic>>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarFormat: _calendarFormat,
                    eventLoader: _getAppointmentsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _loadAppointments();
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: context.textPrimary),
                      weekendTextStyle: TextStyle(color: context.textPrimary),
                      selectedDecoration: BoxDecoration(
                        color: context.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: context.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: context.secondary,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      canMarkersOverflow: true,
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(
                        color: context.textPrimary,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      formatButtonDecoration: BoxDecoration(
                        color: context.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: context.textPrimary,
                        fontSize: isMobile ? 12 : 14,
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: context.textPrimary),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: context.textPrimary),
                      headerPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 16,
                        vertical: 8,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12),
                      weekendStyle: TextStyle(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: isMobile ? 4 : 6,
                              height: isMobile ? 4 : 6,
                              decoration: BoxDecoration(
                                color: context.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
          ),
        ),

        // Appointments for selected day
        Expanded(
          flex: isMobile ? 1 : 2,
          child: Container(
            margin: EdgeInsets.all(isMobile ? 8 : 16),
            child: _buildDayAppointments(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayAppointments() {
    final dayAppointments = _getAppointmentsForDay(_selectedDay);
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return ModernStateWrapper(
      isLoading: _isLoading,
      hasError: _hasError,
      isEmpty: dayAppointments.isEmpty && !_isLoading && !_hasError,
      errorWidget: ModernErrorState(
        title: 'Error Loading Appointments',
        subtitle: _errorMessage,
        onRetry: _loadAppointments,
      ),
      emptyWidget: ModernEmptyState(
        title:
            'No appointments on ${DateFormat('MMM d, yyyy').format(_selectedDay)}',
        subtitle: 'Tap the + button to add an appointment',
        icon: Icons.event_available,
        action: ElevatedButton.icon(
          onPressed: () => _showAddAppointmentDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Appointment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.textPrimary,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(isMobile ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 8 : 16),
            Expanded(
              child: ListView.builder(
                itemCount: dayAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = dayAppointments[index];
                  return _AppointmentCard(
                    appointment: appointment,
                    onEdit: () => _showEditAppointmentDialog(appointment),
                    onCancel: () => _showCancelConfirmDialog(appointment),
                    onComplete: () => _showCompleteConfirmDialog(appointment),
                    onConfirm: () => _showConfirmDialog(appointment),
                    onReject: () => _showRejectDialog(appointment),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ModernStateWrapper(
      isLoading: _isLoading,
      hasError: _hasError,
      isEmpty: _appointments.isEmpty && !_isLoading && !_hasError,
      errorWidget: ModernErrorState(
        title: 'Error Loading Appointments',
        subtitle: _errorMessage,
        onRetry: _loadAppointments,
      ),
      emptyWidget: ModernNoDataState(
        title: 'No appointments found',
        subtitle: 'Tap the + button to add your first appointment',
        action: ElevatedButton.icon(
          onPressed: () => _showAddAppointmentDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Appointment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.textPrimary,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Search and filter bar
            ModernCard(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ModernSearchBar(
                    hintText: 'Search appointments...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ModernFilterChip(
                          label: 'All',
                          selected: _selectedStatus == 'all',
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = 'all';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ModernFilterChip(
                          label: 'Pending',
                          selected: _selectedStatus == 'pending',
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = 'pending';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ModernFilterChip(
                          label: 'Confirmed',
                          selected: _selectedStatus == 'confirmed',
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = 'confirmed';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ModernFilterChip(
                          label: 'Completed',
                          selected: _selectedStatus == 'completed',
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = 'completed';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ModernFilterChip(
                          label: 'Cancelled',
                          selected: _selectedStatus == 'cancelled',
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = 'cancelled';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ModernSortDropdown(
                    value: ModernSortOption(
                      label: _sortBy == 'date'
                          ? 'Date'
                          : _sortBy == 'customer'
                              ? 'Customer'
                              : 'Service',
                      value: _sortBy,
                      icon: _sortBy == 'date'
                          ? Icons.calendar_today
                          : _sortBy == 'customer'
                              ? Icons.person
                              : Icons.content_cut,
                    ),
                    options: [
                      const ModernSortOption(
                        label: 'Date',
                        value: 'date',
                        icon: Icons.calendar_today,
                      ),
                      const ModernSortOption(
                        label: 'Customer',
                        value: 'customer',
                        icon: Icons.person,
                      ),
                      const ModernSortOption(
                        label: 'Service',
                        value: 'service',
                        icon: Icons.content_cut,
                      ),
                    ],
                    onChanged: (option) {
                      setState(() {
                        _sortBy = option!.value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Results count
            if (_searchQuery.isNotEmpty || _selectedStatus != 'all')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_getFilteredAppointments().length} appointment${_getFilteredAppointments().length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        color: context.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedStatus = 'all';
                          _sortBy = 'date';
                        });
                      },
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Appointments list
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ModernPullToRefresh(
                onRefresh: () async {
                  await _loadAppointments();
                },
                child: ResponsiveLayout(
                  mobile: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getFilteredAppointments().length,
                    itemBuilder: (context, index) {
                      final appointment = _getFilteredAppointments()[index];
                      return _AppointmentCard(
                        appointment: appointment,
                        onEdit: () => _showEditAppointmentDialog(appointment),
                        onCancel: () => _showCancelConfirmDialog(appointment),
                        onComplete: () =>
                            _showCompleteConfirmDialog(appointment),
                      );
                    },
                  ),
                  tablet: ResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                    spacing: 16,
                    padding: const EdgeInsets.all(16),
                    children: _getFilteredAppointments().map((appointment) {
                      return _AppointmentCard(
                        appointment: appointment,
                        onEdit: () => _showEditAppointmentDialog(appointment),
                        onCancel: () => _showCancelConfirmDialog(appointment),
                        onComplete: () =>
                            _showCompleteConfirmDialog(appointment),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredAppointments() {
    // Flatten all appointments
    final allAppointments = <Map<String, dynamic>>[];
    for (final appointments in _appointments.values) {
      allAppointments.addAll(appointments);
    }

    // Apply search filter
    var filteredAppointments = allAppointments.where((appointment) {
      if (_searchQuery.isEmpty) return true;

      final customerName = (appointment['customerName'] ?? '').toLowerCase();
      final serviceName = (appointment['serviceName'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return customerName.contains(query) || serviceName.contains(query);
    }).toList();

    // Apply status filter
    if (_selectedStatus != 'all') {
      filteredAppointments = filteredAppointments
          .where((appointment) => appointment['status'] == _selectedStatus)
          .toList();
    }

    // Sort appointments
    filteredAppointments.sort((a, b) {
      switch (_sortBy) {
        case 'date':
          final dateA = DateTime.parse(a['startTime'] ?? a['date'] ?? '');
          final dateB = DateTime.parse(b['startTime'] ?? b['date'] ?? '');
          return dateB.compareTo(dateA);
        case 'customer':
          final nameA = a['customerName'] ?? '';
          final nameB = b['customerName'] ?? '';
          return nameA.compareTo(nameB);
        case 'service':
          final serviceA = a['serviceName'] ?? '';
          final serviceB = b['serviceName'] ?? '';
          return serviceA.compareTo(serviceB);
        default:
          return 0;
      }
    });

    return filteredAppointments;
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AppointmentDialog(
        selectedDate: _selectedDay,
        onSave: (appointmentData) async {
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

            // Create appointment via API
            final response =
                await appointmentService.createAppointment(shopId, {
              ...appointmentData,
              'status': 'scheduled',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Add to local state
            final appointmentDate =
                DateTime.parse(appointmentData['startTime']);
            final dayKey = DateTime(appointmentDate.year, appointmentDate.month,
                appointmentDate.day);

            if (!_appointments.containsKey(dayKey)) {
              _appointments[dayKey] = [];
            }
            _appointments[dayKey]!.add({
              ...response,
              ...appointmentData,
            });

            setState(() {});

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding appointment: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: const Text('Filter functionality will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditAppointmentDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => _AppointmentDialog(
        appointment: appointment,
        selectedDate: DateTime.parse(appointment['startTime']),
        onSave: (appointmentData) async {
          try {
            await appointmentService.updateAppointmentStatus(
              appointment['id'],
              appointment['status'],
              notes: appointmentData['notes'],
            );

            // Update local state
            final appointmentDate = DateTime.parse(appointment['startTime']);
            final dayKey = DateTime(appointmentDate.year, appointmentDate.month,
                appointmentDate.day);

            if (_appointments.containsKey(dayKey)) {
              final index = _appointments[dayKey]!
                  .indexWhere((a) => a['id'] == appointment['id']);
              if (index != -1) {
                _appointments[dayKey]![index] = {
                  ..._appointments[dayKey]![index],
                  ...appointmentData
                };
              }
            }

            setState(() {});

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Appointment updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating appointment: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showCancelConfirmDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel the appointment with ${appointment['customerName'] ?? 'Customer'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await appointmentService.updateAppointmentStatus(
                  appointment['id'],
                  'cancelled',
                );

                // Update local state
                final appointmentDate =
                    DateTime.parse(appointment['startTime']);
                final dayKey = DateTime(appointmentDate.year,
                    appointmentDate.month, appointmentDate.day);

                if (_appointments.containsKey(dayKey)) {
                  final index = _appointments[dayKey]!
                      .indexWhere((a) => a['id'] == appointment['id']);
                  if (index != -1) {
                    _appointments[dayKey]![index]['status'] = 'cancelled';
                  }
                }

                setState(() {});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment cancelled')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error cancelling appointment: $e')),
                  );
                }
              }
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Mark the appointment with ${appointment['customerName'] ?? 'Customer'} as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await appointmentService.updateAppointmentStatus(
                    appointment['id'], 'completed');
                _updateLocalStatus(appointment, 'completed');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment completed')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Confirm the appointment with ${appointment['customerName'] ?? 'Customer'} on ${appointment['startTime'] != null ? DateFormat('MMM d, h:mm a').format(DateTime.parse(appointment['startTime'])) : 'scheduled time'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await appointmentService.confirmAppointment(appointment['id']);
                _updateLocalStatus(appointment, 'confirmed');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment confirmed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> appointment) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject the appointment with ${appointment['customerName'] ?? 'Customer'}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Fully booked, unavailable...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await appointmentService.rejectAppointment(
                  appointment['id'],
                  reason: reasonController.text.trim().isEmpty
                      ? null
                      : reasonController.text.trim(),
                );
                _updateLocalStatus(appointment, 'cancelled');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _updateLocalStatus(Map<String, dynamic> appointment, String newStatus) {
    final dateStr = appointment['startTime'] ?? appointment['date'];
    if (dateStr == null) return;
    final appointmentDate = DateTime.parse(dateStr);
    final dayKey = DateTime(
        appointmentDate.year, appointmentDate.month, appointmentDate.day);
    if (_appointments.containsKey(dayKey)) {
      final index = _appointments[dayKey]!
          .indexWhere((a) => a['id'] == appointment['id']);
      if (index != -1) {
        _appointments[dayKey]![index]['status'] = newStatus;
      }
    }
    setState(() {});
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const _AppointmentCard({
    required this.appointment,
    required this.onEdit,
    required this.onCancel,
    required this.onComplete,
    this.onConfirm,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final status = appointment['status'] ?? 'scheduled';
    final customerName = appointment['customerName'] ?? 'Customer';
    final serviceName = appointment['serviceName'] ?? 'Service';
    final startTime = appointment['startTime'] ?? '';
    final endTime = appointment['endTime'] ?? '';

    return ModernCard(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status indicator
                Container(
                  width: isMobile ? 8 : 12,
                  height: isMobile ? 8 : 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        serviceName,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(startTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    Text(
                      '- ${_formatTime(endTime)}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 12),

            // Status badge and actions
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: isMobile ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                // Action buttons based on status
                if (status == 'pending')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reject button
                      isMobile
                          ? IconButton(
                              onPressed: onReject,
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: Colors.red),
                              tooltip: 'Reject',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            )
                          : TextButton.icon(
                              onPressed: onReject,
                              icon: const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.red),
                              label: const Text('Reject',
                                  style: TextStyle(color: Colors.red)),
                            ),
                      const SizedBox(width: 4),
                      // Confirm button
                      isMobile
                          ? IconButton(
                              onPressed: onConfirm,
                              icon: const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.green),
                              tooltip: 'Confirm',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            )
                          : ElevatedButton.icon(
                              onPressed: onConfirm,
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Confirm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                    ],
                  ),

                if (status == 'scheduled' || status == 'confirmed')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMobile)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        )
                      else
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (!isMobile) ...[
                        TextButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel,
                              size: 16, color: Colors.orange),
                          label: const Text('Cancel',
                              style: TextStyle(color: Colors.orange)),
                        ),
                        TextButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          label: const Text('Complete',
                              style: TextStyle(color: Colors.green)),
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel,
                              size: 16, color: Colors.orange),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ],
                  ),

                if (status == 'cancelled' || status == 'completed')
                  !isMobile
                      ? TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.info, size: 16),
                          label: const Text('View Details'),
                        )
                      : IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.info, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return timeString;
    }
  }
}

class _AppointmentDialog extends StatefulWidget {
  final Map<String, dynamic>? appointment;
  final DateTime selectedDate;
  final Function(Map<String, dynamic>) onSave;

  const _AppointmentDialog({
    this.appointment,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<_AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<_AppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _duration = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;

    if (widget.appointment != null) {
      _customerNameController.text = widget.appointment!['customerName'] ?? '';
      _customerPhoneController.text =
          widget.appointment!['customerPhone'] ?? '';
      _serviceNameController.text = widget.appointment!['serviceName'] ?? '';
      _notesController.text = widget.appointment!['notes'] ?? '';

      if (widget.appointment!['startTime'] != null) {
        final startTime = DateTime.parse(widget.appointment!['startTime']);
        _selectedDate = startTime;
        _selectedTime =
            TimeOfDay(hour: startTime.hour, minute: startTime.minute);
      }

      _duration = widget.appointment!['duration'] ?? 30;
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _serviceNameController.dispose();
    _notesController.dispose();
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
              widget.appointment == null
                  ? 'Add Appointment'
                  : 'Edit Appointment',
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
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter customer name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _customerPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _serviceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Service *',
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

                  Row(
                    children: [
                      // Date picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(_selectedDate),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Time picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: 8),
                                Text(_selectedTime.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  DropdownButtonFormField<int>(
                    value: _duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    items: [15, 30, 45, 60, 90, 120]
                        .map((duration) => DropdownMenuItem(
                              value: duration,
                              child: Text('$duration min'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _duration = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  onPressed: _isLoading ? null : _saveAppointment,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.appointment == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create start and end datetime
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final endDateTime = startDateTime.add(Duration(minutes: _duration));

      final appointmentData = {
        'customerName': _customerNameController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'serviceName': _serviceNameController.text.trim(),
        'startTime': startDateTime.toIso8601String(),
        'endTime': endDateTime.toIso8601String(),
        'duration': _duration,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(startDateTime),
      };

      await widget.onSave(appointmentData);

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
