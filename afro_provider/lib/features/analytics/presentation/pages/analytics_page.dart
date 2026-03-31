import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/di/injection_container.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  bool _isLoading = false;

  // Analytics data
  Map<String, dynamic> _shopAnalytics = {};
  Map<String, dynamic> _earningsData = {};
  Map<String, dynamic> _appointmentStats = {};
  List<Map<String, dynamic>> _servicePerformance = [];
  List<Map<String, dynamic>> _customerInsights = [];
  List<Map<String, dynamic>> _revenueTrends = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get shop ID
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No shop found. Please create a shop first.')),
          );
        }
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Load all analytics data
      final results = await Future.wait([
        analyticsApiService.getShopAnalytics(shopId, period: _selectedPeriod),
        analyticsApiService.getEarningsSummary(),
        analyticsApiService.getAppointmentStats(period: _selectedPeriod),
        analyticsApiService.getServicePerformance(shopId),
        analyticsApiService.getCustomerInsights(shopId),
        analyticsApiService.getRevenueTrends(period: _selectedPeriod),
      ]);

      setState(() {
        _shopAnalytics = results[0] as Map<String, dynamic>;
        _earningsData = results[1] as Map<String, dynamic>;
        _appointmentStats = results[2] as Map<String, dynamic>;
        _servicePerformance = results[3] as List<Map<String, dynamic>>;
        _customerInsights = results[4] as List<Map<String, dynamic>>;
        _revenueTrends = results[5] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppTheme.black),
            onPressed: () => _exportAnalytics(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.black),
            onPressed: () => _loadAnalyticsData(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Period selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Period:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'today', label: Text('Today')),
                          ButtonSegment(value: 'week', label: Text('Week')),
                          ButtonSegment(value: 'month', label: Text('Month')),
                          ButtonSegment(value: 'year', label: Text('Year')),
                        ],
                        selected: {_selectedPeriod},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedPeriod = newSelection.first;
                          });
                          _loadAnalyticsData();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.black,
                unselectedLabelColor: AppTheme.greyMedium,
                indicatorColor: AppTheme.primaryYellow,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Revenue'),
                  Tab(text: 'Services'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRevenueTab(),
                _buildServicesTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildKeyMetricsCards(),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildRevenueChart(),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Earnings Summary
          _buildEarningsSummary(),
          const SizedBox(height: 24),

          // Revenue Trends Chart
          _buildRevenueTrendsChart(),
          const SizedBox(height: 24),

          // Top Services by Revenue
          _buildTopServicesByRevenue(),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Performance
          _buildServicePerformanceChart(),
          const SizedBox(height: 24),

          // Customer Insights
          _buildCustomerInsightsChart(),
          const SizedBox(height: 24),

          // Service Categories
          _buildServiceCategoriesChart(),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards() {
    return Column(
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _MetricCard(
              title: 'Total Revenue',
              value:
                  '\$${(_earningsData['totalRevenue'] ?? 0).toStringAsFixed(2)}',
              change:
                  '+${(_earningsData['revenueChange'] ?? 0).toStringAsFixed(1)}%',
              isPositive: (_earningsData['revenueChange'] ?? 0) >= 0,
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _MetricCard(
              title: 'Total Appointments',
              value: (_appointmentStats['totalAppointments'] ?? 0).toString(),
              change:
                  '+${(_appointmentStats['appointmentsChange'] ?? 0).toStringAsFixed(1)}%',
              isPositive: (_appointmentStats['appointmentsChange'] ?? 0) >= 0,
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'New Customers',
              value: (_customerInsights.isNotEmpty
                      ? _customerInsights[0]['newCustomers'] ?? 0
                      : 0)
                  .toString(),
              change:
                  '+${(_customerInsights.isNotEmpty ? _customerInsights[0]['newCustomersChange'] ?? 0 : 0).toStringAsFixed(1)}%',
              isPositive: (_customerInsights.isNotEmpty
                      ? _customerInsights[0]['newCustomersChange'] ?? 0
                      : 0) >=
                  0,
              icon: Icons.person_add,
              color: Colors.purple,
            ),
            _MetricCard(
              title: 'Avg. Rating',
              value: (_shopAnalytics['averageRating'] ?? 0).toStringAsFixed(1),
              change:
                  '+${(_shopAnalytics['ratingChange'] ?? 0).toStringAsFixed(1)}%',
              isPositive: (_shopAnalytics['ratingChange'] ?? 0) >= 0,
              icon: Icons.star,
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.greyLight,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppTheme.greyLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _revenueTrends.length) {
                          return const Text('');
                        }
                        final data = _revenueTrends[index];
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('MMM d')
                                .format(DateTime.parse(data['date'])),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppTheme.greyLight),
                ),
                minX: 0,
                maxX: (_revenueTrends.length - 1).toDouble(),
                minY: 0,
                maxY: _revenueTrends.isNotEmpty
                    ? _revenueTrends
                            .map((e) => e['revenue'] as double)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2
                    : 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _revenueTrends.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(),
                          entry.value['revenue'] as double);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryYellow, Colors.orange],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryYellow.withOpacity(0.3),
                          Colors.orange.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),

          // Placeholder for recent activity
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Recent activity data will be available soon',
                style: TextStyle(color: AppTheme.greyMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EarningsCard(
                  title: 'Today',
                  amount: (_earningsData['todayEarnings'] ?? 0).toDouble(),
                  change: (_earningsData['todayChange'] ?? 0).toDouble(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EarningsCard(
                  title: 'This Week',
                  amount: (_earningsData['weekEarnings'] ?? 0).toDouble(),
                  change: (_earningsData['weekChange'] ?? 0).toDouble(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EarningsCard(
                  title: 'This Month',
                  amount: (_earningsData['monthEarnings'] ?? 0).toDouble(),
                  change: (_earningsData['monthChange'] ?? 0).toDouble(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _revenueTrends.length) {
                          return const Text('');
                        }
                        final data = _revenueTrends[index];
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('MMM d')
                                .format(DateTime.parse(data['date'])),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _revenueTrends.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['revenue'] as double,
                        color: AppTheme.primaryYellow,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopServicesByRevenue() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Services by Revenue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),

          // Service performance list
          ...(_servicePerformance.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            return _ServicePerformanceItem(
              rank: index + 1,
              serviceName: service['serviceName'] ?? 'Service',
              revenue: (service['revenue'] ?? 0).toDouble(),
              bookings: service['bookings'] ?? 0,
            );
          })),
        ],
      ),
    );
  }

  Widget _buildServicePerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _servicePerformance.take(5).map((service) {
                  final revenue = (service['revenue'] ?? 0).toDouble();
                  final color = _getServiceColor(service['serviceName'] ?? '');
                  return PieChartSectionData(
                    color: color,
                    value: revenue,
                    title:
                        '${((revenue / _servicePerformance.fold(0.0, (sum, s) => sum + (s['revenue'] ?? 0).toDouble())) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInsightsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),

          // Customer insights summary
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
            children: [
              _InsightCard(
                label: 'Total Customers',
                value: (_customerInsights.isNotEmpty
                        ? _customerInsights[0]['totalCustomers'] ?? 0
                        : 0)
                    .toString(),
                icon: Icons.people,
              ),
              _InsightCard(
                label: 'Returning Customers',
                value: (_customerInsights.isNotEmpty
                        ? _customerInsights[0]['returningCustomers'] ?? 0
                        : 0)
                    .toString(),
                icon: Icons.repeat,
              ),
              _InsightCard(
                label: 'Avg. Spend',
                value:
                    '\$${(_customerInsights.isNotEmpty ? _customerInsights[0]['averageSpend'] ?? 0 : 0).toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
              _InsightCard(
                label: 'Loyalty Score',
                value: (_customerInsights.isNotEmpty
                        ? _customerInsights[0]['loyaltyScore'] ?? 0
                        : 0)
                    .toStringAsFixed(1),
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategoriesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),

          // Placeholder for categories chart
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Service categories chart will be available soon',
                style: TextStyle(color: AppTheme.greyMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportAnalytics() {
    // Placeholder for export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Export functionality will be available soon')),
    );
  }

  Color _getServiceColor(String serviceName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    final index = serviceName.hashCode % colors.length;
    return colors[index.abs()];
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title;
  final double amount;
  final double change;

  const _EarningsCard({
    required this.title,
    required this.amount,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.greyMedium,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                change >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: change >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: change >= 0 ? Colors.green : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServicePerformanceItem extends StatelessWidget {
  final int rank;
  final String serviceName;
  final double revenue;
  final int bookings;

  const _ServicePerformanceItem({
    required this.rank,
    required this.serviceName,
    required this.revenue,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Rank
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppTheme.primaryYellow : AppTheme.greyMedium,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Service name
          Expanded(
            child: Text(
              serviceName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),

          // Revenue
          Text(
            '\$${revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(width: 8),

          // Bookings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$bookings',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.greyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.greyMedium,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
