import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../../../core/utils/modern_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_search.dart';
import '../../../../core/widgets/modern_states.dart';
import '../../../../core/widgets/modern_responsive.dart';
import '../../../../core/di/injection_container.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  String _sortBy = 'name';

  // User data
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final users = await userService.getUsers();
      setState(() {
        _users = users as List<Map<String, dynamic>>;
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading users: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    var filtered = List<Map<String, dynamic>>.from(_users);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString().toLowerCase() ?? '';
        final query = _searchController.text.toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    // Apply role filter
    if (_selectedRole != 'All') {
      filtered = filtered
          .where((user) => user['role']?.toString() == _selectedRole)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((user) => user['status']?.toString() == _selectedStatus)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case 'email':
        filtered.sort((a, b) => (a['email'] ?? '').compareTo(b['email'] ?? ''));
        break;
      case 'created':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '');
          final dateB = DateTime.tryParse(b['createdAt'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;
      case 'lastLogin':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['lastLogin'] ?? '');
          final dateB = DateTime.tryParse(b['lastLogin'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: context.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(),
            tooltip: 'Add User',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportUsers,
            tooltip: 'Export Users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          ModernCard(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  ModernSearchBar(
                    controller: _searchController,
                    hintText: 'Search users...',
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items:
                              ['All', 'Admin', 'Staff', 'Manager', 'Customer']
                                  .map((role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: ['All', 'Active', 'Inactive', 'Suspended']
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
                          initialValue: _sortBy,
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
                                value: 'name', child: Text('Name')),
                            DropdownMenuItem(
                                value: 'email', child: Text('Email')),
                            DropdownMenuItem(
                                value: 'created', child: Text('Created Date')),
                            DropdownMenuItem(
                                value: 'lastLogin', child: Text('Last Login')),
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

          // User list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserListView(),
                _buildUserGridView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(),
        tooltip: 'Add User',
        backgroundColor: context.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserListView() {
    return ModernStateWrapper(
      isLoading: _isLoading,
      hasError: _hasError,
      isEmpty: _filteredUsers.isEmpty && !_isLoading && !_hasError,
      errorWidget: ModernErrorState(
        title: 'Error Loading Users',
        subtitle: _errorMessage,
        onRetry: _loadUsers,
      ),
      emptyWidget: ModernEmptyState(
        title: 'No Users Found',
        subtitle: 'Try adjusting your search or filters',
        icon: Icons.person_search,
        action: ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.textPrimary,
          ),
        ),
      ),
      child: ResponsiveLayout(
        mobile: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
            return _UserCard(
              user: user,
              onEdit: () => _showEditUserDialog(user),
              onDelete: () => _showDeleteConfirmDialog(user),
              onToggleStatus: () => _toggleUserStatus(user['id']),
            );
          },
        ),
        tablet: ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          spacing: 16,
          padding: const EdgeInsets.all(16),
          children: _filteredUsers.map((user) {
            return _UserCard(
              user: user,
              onEdit: () => _showEditUserDialog(user),
              onDelete: () => _showDeleteConfirmDialog(user),
              onToggleStatus: () => _toggleUserStatus(user['id']),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserGridView() {
    return Icon(Icons.grid_view);
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _getFilteredUsers();
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _UserDialog(
        title: 'Add User',
        onSave: _addUser,
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _UserDialog(
        title: 'Edit User',
        user: user,
        onSave: (userData) => _updateUser(user['id'], userData),
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser(user['id']);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser(Map<String, dynamic> userData) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await userService.createUser(userData);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating user: $e')),
        );
      }
    }
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await userService.updateUser(userId, userData);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await userService.deleteUser(userId);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _toggleUserStatus(String userId) async {
    try {
      final users = await userService.getUsers();
      final user = users.firstWhere((u) => u['id'] == userId);
      final newStatus = user['status'] == 'Active' ? 'Inactive' : 'Active';

      await userService.updateUserStatus(userId, newStatus);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user status: $e')),
        );
      }
    }
  }

  Future<void> _exportUsers() async {
    try {
      // Create CSV content
      final csvData = [
        [
          'Name',
          'Email',
          'Phone',
          'Role',
          'Status',
          'Created Date',
          'Last Login'
        ],
        ..._filteredUsers.map((user) => [
              user['name'] ?? '',
              user['email'] ?? '',
              user['phone'] ?? '',
              user['role'] ?? '',
              user['status'] ?? '',
              user['createdAt'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(DateTime.parse(user['createdAt']))
                  : '',
              user['lastLogin'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(DateTime.parse(user['lastLogin']))
                  : '',
            ]),
      ];

      // Convert to CSV string
      final csvString = csvData.map((row) => row.join(',')).join('\n');

      // Create download
      final bytes = utf8.encode(csvString);
      final blob = html.Blob([bytes]);

      // Create download link
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            'download', 'users_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();

      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Users exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting users: $e')),
        );
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = user['status'] ?? 'Unknown';
    final isActive = status == 'Active';

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User avatar and info
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            isActive ? context.primary : context.textSecondary,
                        child: Text(
                          (user['name'] ?? '').isNotEmpty
                              ? (user['name'] ?? '')[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user['phone'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 12),

            // Role and dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role: ${user['role'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${user['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(user['createdAt'])) : 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Last Login: ${user['lastLogin'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(user['lastLogin'])) : 'Never'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 16),
                            tooltip: 'Edit User',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onToggleStatus,
                            icon: Icon(
                              isActive ? Icons.block : Icons.check_circle,
                              size: 16,
                              color: isActive ? Colors.orange : Colors.green,
                            ),
                            tooltip:
                                isActive ? 'Deactivate User' : 'Activate User',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete,
                                size: 16, color: Colors.red),
                            tooltip: 'Delete User',
                          ),
                        ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _UserDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? user;
  final Function(Map<String, dynamic>) onSave;

  const _UserDialog({
    required this.title,
    this.user,
    required this.onSave,
  });

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Staff';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _nameController.text = widget.user!['name'] ?? '';
      _emailController.text = widget.user!['email'] ?? '';
      _phoneController.text = widget.user!['phone'] ?? '';
      _selectedRole = widget.user!['role'] ?? 'Staff';
      _isActive = widget.user!['status'] == 'Active';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
                      initialValue:
                          widget.user != null ? widget.user!['name'] : '',
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
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
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Admin', 'Staff', 'Manager', 'Customer']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
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
                          child: CheckboxListTile(
                            title: const Text('Active'),
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value!;
                              });
                            },
                          ),
                        ),
                      ],
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
                          onPressed: _saveUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.textPrimary,
                          ),
                          child: Text(widget.user == null
                              ? 'Create User'
                              : 'Update User'),
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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'status': _isActive ? 'Active' : 'Inactive',
        if (widget.user != null) ...{
          'id': widget.user!['id'],
        },
      };

      await widget.onSave(userData);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user: $e')),
        );
      }
    }
  }
}
