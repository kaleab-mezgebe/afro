import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/modern_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_search.dart';
import '../../../../core/widgets/modern_states.dart';
import '../../../../core/widgets/modern_responsive.dart';
import '../../../../core/di/injection_container.dart';

class TransactionManagementPage extends ConsumerStatefulWidget {
  const TransactionManagementPage({super.key});

  @override
  ConsumerState<TransactionManagementPage> createState() =>
      _TransactionManagementPageState();
}

class _TransactionManagementPageState
    extends ConsumerState<TransactionManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  String _sortBy = 'date';
  String _dateRange = 'all';

  // Transaction data
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Load transactions and stats in parallel
      final results = await Future.wait([
        transactionService.getTransactions(),
        transactionService.getTransactionStats(period: _dateRange),
        transactionService.getRevenueSummary(period: _dateRange),
      ]);

      setState(() {
        _transactions =
            (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
        _stats = {
          ...results[1] as Map<String, dynamic>,
          ...results[2] as Map<String, dynamic>,
        };
        _filteredTransactions = _transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading transactions: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    var filtered = List<Map<String, dynamic>>.from(_transactions);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((transaction) {
        final id = transaction['id']?.toString().toLowerCase() ?? '';
        final customerName =
            transaction['customerName']?.toString().toLowerCase() ?? '';
        final customerEmail =
            transaction['customerEmail']?.toString().toLowerCase() ?? '';
        final amount = transaction['amount']?.toString() ?? '';
        final status = transaction['status']?.toString().toLowerCase() ?? '';

        return id.contains(query) ||
            customerName.contains(query) ||
            customerEmail.contains(query) ||
            amount.contains(query) ||
            status.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((transaction) =>
              transaction['status']?.toString() == _selectedStatus)
          .toList();
    }

    // Apply type filter
    if (_selectedType != 'All') {
      filtered = filtered
          .where(
              (transaction) => transaction['type']?.toString() == _selectedType)
          .toList();
    }

    // Apply date range filter
    if (_dateRange != 'all') {
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;

      switch (_dateRange) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 0, 0, 0);
          break;
      }

      filtered = filtered.where((transaction) {
        if (transaction['createdAt'] == null) return false;
        final transactionDate = DateTime.parse(transaction['createdAt']);
        return transactionDate.isAfter(startDate!) &&
            transactionDate.isBefore(endDate!);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '');
          final dateB = DateTime.tryParse(b['createdAt'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB!.compareTo(dateA!);
        });
        break;
      case 'amount':
        filtered.sort((a, b) {
          final amountA = double.tryParse(a['amount']?.toString() ?? '0') ?? 0;
          final amountB = double.tryParse(b['amount']?.toString() ?? '0') ?? 0;
          return amountB.compareTo(amountA);
        });
        break;
      case 'status':
        filtered
            .sort((a, b) => (a['status'] ?? '').compareTo(b['status'] ?? ''));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Transaction Management'),
        backgroundColor: context.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(),
            tooltip: 'Add Transaction',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportTransactions,
            tooltip: 'Export Transactions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          ModernCard(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ResponsiveLayout(
                mobile: Column(
                  children: [
                    _buildStatCard(
                        'Total Revenue',
                        '\$${(_stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                        Icons.attach_money,
                        context.success),
                    const SizedBox(height: 12),
                    _buildStatCard(
                        'Total Transactions',
                        '${_stats['totalTransactions'] ?? 0}',
                        Icons.receipt_long,
                        context.primary),
                  ],
                ),
                tablet: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total Revenue',
                            '\$${(_stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                            Icons.attach_money,
                            context.success)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Total Transactions',
                            '${_stats['totalTransactions'] ?? 0}',
                            Icons.receipt_long,
                            context.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Average Transaction',
                            '\$${(_stats['averageTransaction'] ?? 0).toStringAsFixed(2)}',
                            Icons.trending_up,
                            context.warning)),
                  ],
                ),
                desktop: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total Revenue',
                            '\$${(_stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                            Icons.attach_money,
                            context.success)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Total Transactions',
                            '${_stats['totalTransactions'] ?? 0}',
                            Icons.receipt_long,
                            context.primary)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Average Transaction',
                            '\$${(_stats['averageTransaction'] ?? 0).toStringAsFixed(2)}',
                            Icons.trending_up,
                            context.warning)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Pending Refunds',
                            '${_stats['pendingRefunds'] ?? 0}',
                            Icons.refresh,
                            context.error)),
                  ],
                ),
              ),
            ),
          ),

          // Search and filters
          ModernCard(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  ModernSearchBar(
                    controller: _searchController,
                    hintText: 'Search transactions...',
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            'All',
                            'Completed',
                            'Pending',
                            'Failed',
                            'Refunded'
                          ]
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items:
                              ['All', 'Payment', 'Refund', 'Chargeback', 'Fee']
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _dateRange,
                          decoration: InputDecoration(
                            labelText: 'Date Range',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: ['All', 'Today', 'Week', 'Month']
                              .map((range) => DropdownMenuItem(
                                    value: range,
                                    child: Text(range),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _dateRange = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sortBy,
                          decoration: InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: 'date', child: Text('Date')),
                            DropdownMenuItem(
                                value: 'amount', child: Text('Amount')),
                            DropdownMenuItem(
                                value: 'status', child: Text('Status')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Transaction list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionListView(),
                _buildTransactionGridView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        tooltip: 'Add Transaction',
        backgroundColor: context.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListView() {
    return ModernStateWrapper(
      isLoading: _isLoading,
      hasError: _hasError,
      isEmpty: _filteredTransactions.isEmpty && !_isLoading && !_hasError,
      errorWidget: ModernErrorState(
        title: 'Error Loading Transactions',
        subtitle: _errorMessage,
        onRetry: _loadTransactions,
      ),
      emptyWidget: ModernEmptyState(
        title: 'No Transactions Found',
        subtitle: 'Try adjusting your filters or add a new transaction',
        icon: Icons.receipt_long,
        action: ElevatedButton.icon(
          onPressed: () => _showAddTransactionDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Transaction'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.textPrimary,
          ),
        ),
      ),
      child: ResponsiveLayout(
        mobile: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredTransactions.length,
          itemBuilder: (context, index) {
            final transaction = _filteredTransactions[index];
            return _TransactionCard(
              transaction: transaction,
              onView: () => _showTransactionDetailsDialog(transaction),
              onRefund: () => _showRefundConfirmDialog(transaction),
              onUpdateStatus: () => _showUpdateStatusDialog(transaction),
            );
          },
        ),
        tablet: ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          spacing: 16,
          padding: const EdgeInsets.all(16),
          children: _filteredTransactions.map((transaction) {
            return _TransactionCard(
              transaction: transaction,
              onView: () => _showTransactionDetailsDialog(transaction),
              onRefund: () => _showRefundConfirmDialog(transaction),
              onUpdateStatus: () => _showUpdateStatusDialog(transaction),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionGridView() {
    return Icon(Icons.grid_view);
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _getFilteredTransactions();
    });
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => _TransactionDialog(
        title: 'Add Transaction',
        onSave: _addTransaction,
      ),
    );
  }

  void _showTransactionDetailsDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => _TransactionDialog(
        title: 'Transaction Details',
        transaction: transaction,
        readOnly: true,
        onSave: (data) {}, // No-op function for read-only mode
      ),
    );
  }

  void _showRefundConfirmDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Transaction'),
        content: Text('Are you sure you want to refund this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refundTransaction(transaction);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> transaction) {
    final statuses = ['Completed', 'Pending', 'Failed'];
    String selectedStatus = transaction['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Transaction Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedStatus,
              items: statuses
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateTransactionStatus(transaction['id'], selectedStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(Map<String, dynamic> transactionData) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await transactionService.createTransaction(transactionData);
      await _loadTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction created successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating transaction: $e')),
        );
      }
    }
  }

  Future<void> _refundTransaction(Map<String, dynamic> transaction) async {
    try {
      await transactionService
          .refundTransaction(transaction['id'], {'reason': 'Customer request'});
      await _loadTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction refunded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refunding transaction: $e')),
        );
      }
    }
  }

  Future<void> _updateTransactionStatus(
      String transactionId, String status) async {
    try {
      await transactionService.updateTransactionStatus(transactionId, status);
      await _loadTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction status: $e')),
        );
      }
    }
  }

  Future<void> _exportTransactions() async {
    try {
      final transactions = _getFilteredTransactions();

      // Create CSV content
      final csvData = [
        [
          'ID',
          'Customer',
          'Email',
          'Phone',
          'Amount',
          'Status',
          'Date',
          'Type'
        ],
        ...transactions.map((transaction) => [
              transaction['id'] ?? '',
              transaction['customerName'] ?? '',
              transaction['customerEmail'] ?? '',
              transaction['customerPhone'] ?? '',
              '\$${transaction['amount'] ?? ''}',
              transaction['status'] ?? '',
              transaction['createdAt'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(DateTime.parse(transaction['createdAt']))
                  : '',
              transaction['type'] ?? '',
            ]),
      ];

      // Convert to CSV string
      final csvString = csvData.map((row) => row.join(',')).join('\n');

      // Export functionality - for mobile platforms, show message
      // TODO: Implement mobile-specific export using share_plus or similar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Export feature - CSV data ready: ${csvString.length} bytes')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting transactions: $e')),
        );
      }
    }
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onView;
  final VoidCallback onRefund;
  final VoidCallback onUpdateStatus;

  const _TransactionCard({
    super.key,
    required this.transaction,
    required this.onView,
    required this.onRefund,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = transaction['status'] ?? 'Unknown';
    final amount = '\$${transaction['amount'] ?? '0.00'}';
    final isRefunded = status == 'Refunded';

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Transaction info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['customerName'] ?? 'Unknown Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['customerEmail'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(
                          DateTime.tryParse(transaction['createdAt'] ?? '') ??
                              DateTime.now(),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.info, size: 16),
                      label: const Text('Details'),
                    ),
                    const SizedBox(height: 4),
                    if (!isRefunded) ...[
                      TextButton.icon(
                        onPressed: onUpdateStatus,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Update'),
                      ),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: onRefund,
                        icon: const Icon(Icons.refresh,
                            size: 16, color: Colors.orange),
                        label: const Text('Refund'),
                      ),
                    ],
                  ],
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
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _TransactionDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? transaction;
  final Function(Map<String, dynamic>) onSave;
  final bool readOnly;

  const _TransactionDialog({
    required this.title,
    this.transaction,
    required this.onSave,
    this.readOnly = false,
  });

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Payment';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _customerNameController.text = widget.transaction!['customerName'] ?? '';
      _customerEmailController.text =
          widget.transaction!['customerEmail'] ?? '';
      _customerPhoneController.text =
          widget.transaction!['customerPhone'] ?? '';
      _amountController.text = widget.transaction!['amount']?.toString() ?? '';
      _descriptionController.text = widget.transaction!['description'] ?? '';
      _selectedType = widget.transaction!['type'] ?? 'Payment';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
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
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Customer name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Email *',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Customer email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Phone',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
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
                      enabled: !widget.readOnly,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Payment', 'Refund', 'Chargeback', 'Fee']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: widget.readOnly
                          ? null
                          : (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.textPrimary,
                          ),
                          child: Text(widget.readOnly ? 'View' : 'Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final transactionData = {
        'customerName': _customerNameController.text.trim(),
        'customerEmail': _customerEmailController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'amount': _amountController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'status': 'Completed',
        if (widget.transaction != null) ...{
          'id': widget.transaction!['id'],
        },
      };

      await widget.onSave(transactionData);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    }
  }
}
