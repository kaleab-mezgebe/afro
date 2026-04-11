import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../../../core/utils/modern_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_search.dart';
import '../../../../core/widgets/modern_states.dart';
import '../../../../core/widgets/modern_responsive.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/review_service.dart';

class ReviewManagementPage extends ConsumerStatefulWidget {
  const ReviewManagementPage({super.key});

  @override
  ConsumerState<ReviewManagementPage> createState() =>
      _ReviewManagementPageState();
}

class _ReviewManagementPageState extends ConsumerState<ReviewManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedRating = 'All';
  String _sortBy = 'date';
  String _dateRange = 'all';

  // Review data
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _filteredReviews = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Load reviews and stats in parallel
      final results = await Future.wait([
        reviewService.getReviews(),
        reviewService.getReviewStats(period: _dateRange),
      ]);

      setState(() {
        _reviews = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
        _stats = results[1] as Map<String, dynamic>;
        _filteredReviews = _reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading reviews: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredReviews() {
    var filtered = List<Map<String, dynamic>>.from(_reviews);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((review) {
        final id = review['id']?.toString().toLowerCase() ?? '';
        final customerName =
            review['customerName']?.toString().toLowerCase() ?? '';
        final content = review['content']?.toString().toLowerCase() ?? '';
        final rating = review['rating']?.toString() ?? '';
        final status = review['status']?.toString().toLowerCase() ?? '';

        return id.contains(query) ||
            customerName.contains(query) ||
            content.contains(query) ||
            rating.contains(query) ||
            status.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((review) => review['status']?.toString() == _selectedStatus)
          .toList();
    }

    // Apply rating filter
    if (_selectedRating != 'All') {
      filtered = filtered
          .where((review) => review['rating']?.toString() == _selectedRating)
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

      filtered = filtered.where((review) {
        if (review['createdAt'] == null) return false;
        final reviewDate = DateTime.parse(review['createdAt']);
        return reviewDate.isAfter(startDate!) && reviewDate.isBefore(endDate!);
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
      case 'rating':
        filtered.sort((a, b) {
          final ratingA = double.tryParse(a['rating']?.toString() ?? '0') ?? 0;
          final ratingB = double.tryParse(b['rating']?.toString() ?? '0') ?? 0;
          return ratingB.compareTo(ratingA);
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
        title: const Text('Review Management'),
        backgroundColor: context.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReviewDialog(),
            tooltip: 'Add Review',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReviews,
            tooltip: 'Export Reviews',
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
                        'Total Reviews',
                        '${_stats['totalReviews'] ?? 0}',
                        Icons.reviews,
                        context.primary),
                    const SizedBox(height: 12),
                    _buildStatCard(
                        'Average Rating',
                        '${(_stats['averageRating'] ?? 0).toStringAsFixed(1)}',
                        Icons.star,
                        context.warning),
                  ],
                ),
                tablet: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total Reviews',
                            '${_stats['totalReviews'] ?? 0}',
                            Icons.reviews,
                            context.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Average Rating',
                            '${(_stats['averageRating'] ?? 0).toStringAsFixed(1)}',
                            Icons.star,
                            context.warning)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Pending Reviews',
                            '${_stats['pendingReviews'] ?? 0}',
                            Icons.pending,
                            context.error)),
                  ],
                ),
                desktop: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total Reviews',
                            '${_stats['totalReviews'] ?? 0}',
                            Icons.reviews,
                            context.primary)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Average Rating',
                            '${(_stats['averageRating'] ?? 0).toStringAsFixed(1)}',
                            Icons.star,
                            context.warning)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Pending Reviews',
                            '${_stats['pendingReviews'] ?? 0}',
                            Icons.pending,
                            context.error)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard(
                            'Flagged Reviews',
                            '${_stats['flaggedReviews'] ?? 0}',
                            Icons.flag,
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
                    hintText: 'Search reviews...',
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
                            'Approved',
                            'Pending',
                            'Hidden',
                            'Flagged'
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
                          value: _selectedRating,
                          decoration: InputDecoration(
                            labelText: 'Rating',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            'All',
                            '5 Stars',
                            '4 Stars',
                            '3 Stars',
                            '2 Stars',
                            '1 Star'
                          ]
                              .map((rating) => DropdownMenuItem(
                                    value: rating,
                                    child: Text(rating),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRating = value!;
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
                                value: 'rating', child: Text('Rating')),
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
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Review list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewListView(),
                _buildReviewGridView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReviewDialog(),
        tooltip: 'Add Review',
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

  Widget _buildReviewListView() {
    return ModernStateWrapper(
      isLoading: _isLoading,
      hasError: _hasError,
      isEmpty: _filteredReviews.isEmpty && !_isLoading && !_hasError,
      errorWidget: ModernErrorState(
        title: 'Error Loading Reviews',
        subtitle: _errorMessage,
        onRetry: _loadReviews,
      ),
      emptyWidget: ModernEmptyState(
        title: 'No Reviews Found',
        subtitle: 'Try adjusting your filters or add a new review',
        icon: Icons.reviews,
        action: ElevatedButton.icon(
          onPressed: () => _showAddReviewDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.textPrimary,
          ),
        ),
      ),
      child: ResponsiveLayout(
        mobile: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredReviews.length,
          itemBuilder: (context, index) {
            final review = _filteredReviews[index];
            return _ReviewCard(
              review: review,
              onView: () => _showReviewDetailsDialog(review),
              onApprove: () => _approveReview(review),
              onHide: () => _hideReview(review),
              onDelete: () => _showDeleteConfirmDialog(review),
              onFlag: () => _flagReview(review),
              onRespond: () => _showRespondDialog(review),
            );
          },
        ),
        tablet: ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          spacing: 16,
          padding: const EdgeInsets.all(16),
          children: _filteredReviews.map((review) {
            return _ReviewCard(
              review: review,
              onView: () => _showReviewDetailsDialog(review),
              onApprove: () => _approveReview(review),
              onHide: () => _hideReview(review),
              onDelete: () => _showDeleteConfirmDialog(review),
              onFlag: () => _flagReview(review),
              onRespond: () => _showRespondDialog(review),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReviewGridView() {
    return Icon(Icons.grid_view);
  }

  void _applyFilters() {
    setState(() {
      _filteredReviews = _getFilteredReviews();
    });
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReviewDialog(
        title: 'Add Review',
        onSave: _addReview,
      ),
    );
  }

  void _showReviewDetailsDialog(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => _ReviewDialog(
        title: 'Review Details',
        review: review,
        readOnly: true,
        onSave: (reviewData) {}, // Empty function since this is read-only
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReview(review['id'].toString());
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

  void _approveReview(Map<String, dynamic> review) async {
    try {
      await reviewService.updateReviewStatus(review['id'], 'Approved');
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving review: $e')),
        );
      }
    }
  }

  void _hideReview(Map<String, dynamic> review) async {
    try {
      await reviewService.updateReviewStatus(review['id'], 'Hidden');
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review hidden successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error hiding review: $e')),
        );
      }
    }
  }

  void _flagReview(Map<String, dynamic> review) async {
    try {
      await reviewService.updateReviewStatus(review['id'], 'Flagged');
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review flagged successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error flagging review: $e')),
        );
      }
    }
  }

  void _showRespondDialog(Map<String, dynamic> review) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Write your response:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your response here...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _respondToReview(review, responseController.text);
                  },
                  child: const Text('Send Response'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respondToReview(
      Map<String, dynamic> review, String response) async {
    try {
      await reviewService.respondToReview(review['id'], {'response': response});
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending response: $e')),
        );
      }
    }
  }

  Future<void> _addReview(Map<String, dynamic> reviewData) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await reviewService.createReview(reviewData);
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review created successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating review: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await reviewService.deleteReview(reviewId);
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting review: $e')),
        );
      }
    }
  }

  Future<void> _exportReviews() async {
    try {
      final reviews = _getFilteredReviews();

      // Create CSV content
      final csvData = [
        ['ID', 'Customer', 'Rating', 'Status', 'Date', 'Content'],
        ...reviews.map((review) => [
              review['id'] ?? '',
              review['customerName'] ?? '',
              review['rating'] ?? '',
              review['status'] ?? '',
              review['createdAt'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(DateTime.parse(review['createdAt']))
                  : '',
              review['content'] ?? '',
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
            'download', 'reviews_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();

      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reviews exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting reviews: $e')),
        );
      }
    }
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onHide;
  final VoidCallback onDelete;
  final VoidCallback onFlag;
  final VoidCallback onRespond;

  const _ReviewCard({
    super.key,
    required this.review,
    required this.onView,
    required this.onApprove,
    required this.onHide,
    required this.onDelete,
    required this.onFlag,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    final status = review['status'] ?? 'Unknown';
    final rating = double.tryParse(review['rating']?.toString() ?? '0') ?? 0;
    final isPending = status == 'Pending';
    final isApproved = status == 'Approved';
    final isHidden = status == 'Hidden';
    final isFlagged = status == 'Flagged';

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['customerName'] ?? 'Unknown Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Rating stars
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : index == rating.floor()
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(
                          DateTime.tryParse(review['createdAt'] ?? '') ??
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

            // Review content
            Text(
              review['content'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),

                // Action buttons based on status
                if (isPending) ...[
                  TextButton.icon(
                    onPressed: onApprove,
                    icon:
                        const Icon(Icons.check, size: 16, color: Colors.green),
                    label: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onHide,
                    icon: const Icon(Icons.visibility_off,
                        size: 16, color: Colors.orange),
                    label: const Text('Hide'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text('Delete'),
                  ),
                ] else if (isApproved || isHidden) ...[
                  TextButton.icon(
                    onPressed: onFlag,
                    icon: const Icon(Icons.flag, size: 16, color: Colors.red),
                    label: const Text('Flag'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onRespond,
                    icon: const Icon(Icons.reply, size: 16, color: Colors.blue),
                    label: const Text('Respond'),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'hidden':
        return Colors.grey;
      case 'flagged':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class _ReviewDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? review;
  final Function(Map<String, dynamic>) onSave;
  final bool readOnly;

  const _ReviewDialog({
    required this.title,
    this.review,
    required this.onSave,
    this.readOnly = false,
  });

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _contentController = TextEditingController();
  final _serviceController = TextEditingController();
  String _selectedRating = '5';

  @override
  void initState() {
    super.initState();

    if (widget.review != null) {
      _customerNameController.text = widget.review!['customerName'] ?? '';
      _ratingController.text = widget.review!['rating']?.toString() ?? '';
      _contentController.text = widget.review!['content'] ?? '';
      _serviceController.text = widget.review!['serviceName'] ?? '';
      _selectedRating = widget.review!['rating']?.toString() ?? '5';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _ratingController.dispose();
    _contentController.dispose();
    _serviceController.dispose();
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
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (1-5)',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Rating is required';
                        }
                        final rating = int.tryParse(value);
                        if (rating == null || rating < 1 || rating > 5) {
                          return 'Rating must be between 1 and 5';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Review Content *',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Review content is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceController,
                      decoration: const InputDecoration(
                        labelText: 'Service',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !widget.readOnly,
                    ),
                    const SizedBox(height: 16),
                    IgnorePointer(
                      ignoring: widget.readOnly,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRating,
                        decoration: const InputDecoration(
                          labelText: 'Rating *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: widget.readOnly
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedRating = value!;
                                });
                              },
                        items: ['5', '4', '3', '2', '1']
                            .map((rating) => DropdownMenuItem(
                                  value: rating,
                                  child: Text('$rating Stars'),
                                ))
                            .toList(),
                      ),
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
                          onPressed: _saveReview,
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

  Future<void> _saveReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final reviewData = {
        'customerName': _customerNameController.text.trim(),
        'rating': int.parse(_ratingController.text),
        'content': _contentController.text.trim(),
        'serviceName': _serviceController.text.trim(),
        if (widget.review != null) ...{
          'id': widget.review!['id'],
        },
      };

      await widget.onSave(reviewData);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving review: $e')),
        );
      }
    }
  }
}
