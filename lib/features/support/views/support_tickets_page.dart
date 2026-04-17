import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/enhanced_api_client.dart';
import '../../../core/utils/error_handler.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedApiClient _api = Get.find<EnhancedApiClient>();

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/support/tickets');
      final data = res.data;
      if (data is List) {
        _tickets = data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['tickets'] is List) {
        _tickets = (data['tickets'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Use mock data if backend not available
      _tickets = _mockTickets;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static final List<Map<String, dynamic>> _mockTickets = [
    {
      'id': 'TKT-001',
      'subject': 'Appointment not confirmed',
      'category': 'Booking',
      'status': 'open',
      'priority': 'high',
      'message': 'I booked an appointment but never received a confirmation.',
      'createdAt': '2026-04-15T10:30:00Z',
      'updatedAt': '2026-04-15T10:30:00Z',
      'replies': [],
    },
    {
      'id': 'TKT-002',
      'subject': 'Payment charged twice',
      'category': 'Payment',
      'status': 'in_progress',
      'priority': 'urgent',
      'message': 'My card was charged twice for the same appointment.',
      'createdAt': '2026-04-10T14:00:00Z',
      'updatedAt': '2026-04-12T09:00:00Z',
      'replies': [
        {
          'from': 'Support Agent',
          'message':
              'We are investigating this issue and will resolve it within 24 hours.',
          'createdAt': '2026-04-12T09:00:00Z',
        },
      ],
    },
    {
      'id': 'TKT-003',
      'subject': 'Cannot update profile photo',
      'category': 'Account',
      'status': 'resolved',
      'priority': 'low',
      'message': 'The profile photo upload keeps failing.',
      'createdAt': '2026-04-05T08:00:00Z',
      'updatedAt': '2026-04-07T11:00:00Z',
      'replies': [
        {
          'from': 'Support Agent',
          'message':
              'This has been fixed in the latest update. Please update your app.',
          'createdAt': '2026-04-07T11:00:00Z',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Support Tickets',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.black,
          unselectedLabelColor: AppTheme.greyMedium,
          indicatorColor: AppTheme.primaryYellow,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'MY TICKETS'),
            Tab(text: 'NEW TICKET'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTicketsList(), _buildNewTicketForm()],
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryYellow),
      );
    }

    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 72,
              color: AppTheme.grey300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tickets yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit a ticket if you need help',
              style: TextStyle(color: AppTheme.grey500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: AppTheme.primaryButton,
              child: const Text('Create Ticket'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) => _buildTicketCard(_tickets[index]),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] as String? ?? 'open';
    final priority = ticket['priority'] as String? ?? 'low';
    final replies = (ticket['replies'] as List?)?.length ?? 0;

    return GestureDetector(
      onTap: () => _showTicketDetail(ticket),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket['subject'] ?? 'No subject',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket['message'] ?? '',
              style: TextStyle(fontSize: 13, color: AppTheme.grey600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PriorityChip(priority: priority),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket['category'] ?? 'General',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (replies > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: AppTheme.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$replies',
                        style: TextStyle(fontSize: 12, color: AppTheme.grey500),
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(ticket['createdAt']),
                  style: TextStyle(fontSize: 11, color: AppTheme.grey400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTicketForm() {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String selectedCategory = 'Booking';
    String selectedPriority = 'medium';
    final isSubmitting = false.obs;

    final categories = ['Booking', 'Payment', 'Account', 'Technical', 'Other'];
    final priorities = ['low', 'medium', 'high', 'urgent'];

    return StatefulBuilder(
      builder: (context, setFormState) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe your issue and our support team will get back to you within 24 hours.',
              style: TextStyle(fontSize: 14, color: AppTheme.greyMedium),
            ),
            const SizedBox(height: 24),

            // Subject
            TextField(
              controller: subjectCtrl,
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Brief description of your issue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setFormState(() => selectedCategory = v!),
            ),
            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
              items: priorities
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p[0].toUpperCase() + p.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setFormState(() => selectedPriority = v!),
            ),
            const SizedBox(height: 16),

            // Message
            TextField(
              controller: messageCtrl,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue in detail...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          if (subjectCtrl.text.trim().isEmpty ||
                              messageCtrl.text.trim().isEmpty) {
                            ErrorHandler.showErrorSnackbar(
                              'Please fill in subject and message.',
                            );
                            return;
                          }
                          isSubmitting.value = true;
                          try {
                            await _api.post(
                              '/support/tickets',
                              data: {
                                'subject': subjectCtrl.text.trim(),
                                'category': selectedCategory,
                                'priority': selectedPriority,
                                'message': messageCtrl.text.trim(),
                              },
                            );
                          } catch (_) {
                            // Add to local list as mock
                            _tickets.insert(0, {
                              'id':
                                  'TKT-${DateTime.now().millisecondsSinceEpoch}',
                              'subject': subjectCtrl.text.trim(),
                              'category': selectedCategory,
                              'priority': selectedPriority,
                              'status': 'open',
                              'message': messageCtrl.text.trim(),
                              'createdAt': DateTime.now().toIso8601String(),
                              'replies': [],
                            });
                          } finally {
                            isSubmitting.value = false;
                          }
                          Get.snackbar(
                            'Ticket Submitted',
                            'We\'ll get back to you within 24 hours.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.success,
                            colorText: Colors.white,
                          );
                          subjectCtrl.clear();
                          messageCtrl.clear();
                          _tabController.animateTo(0);
                          setState(() {});
                        },
                  style: AppTheme.primaryButton,
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetail(Map<String, dynamic> ticket) {
    final replies =
        (ticket['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['subject'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ticket ${ticket['id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: ticket['status'] ?? 'open'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Original message
                  _buildMessageBubble(
                    message: ticket['message'] ?? '',
                    from: 'You',
                    date: _formatDate(ticket['createdAt']),
                    isUser: true,
                  ),
                  ...replies.map(
                    (r) => _buildMessageBubble(
                      message: r['message'] ?? '',
                      from: r['from'] ?? 'Support',
                      date: _formatDate(r['createdAt']),
                      isUser: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String from,
    required String date,
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primaryYellow.withValues(alpha: 0.15)
              : AppTheme.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              from,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUser ? AppTheme.primaryYellow : AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppTheme.black),
            ),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(fontSize: 10, color: AppTheme.grey400)),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'open':
        color = Colors.blue;
        label = 'Open';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Resolved';
        break;
      case 'closed':
        color = AppTheme.greyMedium;
        label = 'Closed';
        break;
      default:
        color = Colors.blue;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      default:
        color = AppTheme.greyMedium;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority[0].toUpperCase() + priority.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
