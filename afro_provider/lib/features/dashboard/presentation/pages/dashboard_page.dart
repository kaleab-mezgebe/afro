import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/utils/app_theme.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AFRO PROVIDER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Trigger refresh logic
                ref.invalidate(dashboardProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Profile Section
                    _WelcomeSection(),
                    const SizedBox(height: 24),

                    // Today's Stats Grid
                    _QuickStatsGrid(),
                    const SizedBox(height: 32),

                    // Modern Revenue Chart Card
                    _RevenueChart(),
                    const SizedBox(height: 32),

                    // Next Appointment Card
                    _RecentAppointments(),
                    const SizedBox(height: 32),

                    // Quick Shortcuts Section
                    _QuickActions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.greyMedium,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Afro Barber Shop',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.storefront_outlined, color: AppTheme.black),
        ),
      ],
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            _StatCard(
              title: 'Revenue Today',
              value: '\$ 1,250',
              icon: Icons
                  .currency_bitcoin, // Using bitcoin as placeholder for modern look or generic money
              color: AppTheme.primaryYellow,
              width: (constraints.maxWidth - 16) / 2,
            ),
            const SizedBox(width: 16),
            _StatCard(
              title: 'Appointments',
              value: '12',
              icon: Icons.calendar_today_outlined,
              color: AppTheme.black,
              width: (constraints.maxWidth - 16) / 2,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color == AppTheme.black ? AppTheme.black : AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          if (color == AppTheme.primaryYellow)
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: TextStyle(
              color: color == AppTheme.black ? Colors.white : AppTheme.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color == AppTheme.black
                  ? Colors.grey[400]
                  : AppTheme.greyMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'This Week',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 1.4),
                      FlSpot(3, 2.2),
                      FlSpot(4, 1.8),
                      FlSpot(5, 2.8),
                      FlSpot(6, 2.5),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryYellow,
                    barWidth: 6,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryYellow.withOpacity(0.3),
                          AppTheme.primaryYellow.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Text(
                      day,
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecentAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All',
                  style: TextStyle(color: AppTheme.primaryYellow)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AppointmentTile(
          customerName: 'Kaleab Mezgebe',
          service: 'Luxury Haircut + Beard',
          time: 'Today, 2:30 PM',
          status: 'Confirmed',
        ),
        const SizedBox(height: 12),
        _AppointmentTile(
          customerName: 'John Doe',
          service: 'Facial & Scrub',
          time: 'Today, 4:00 PM',
          status: 'Confirmed',
        ),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String customerName;
  final String service;
  final String time;
  final String status;

  const _AppointmentTile({
    required this.customerName,
    required this.service,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAED), // Very light yellow tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.access_time_filled,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  service,
                  style:
                      const TextStyle(color: AppTheme.greyMedium, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            time.split(',')[1].trim(),
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: AppTheme.black),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Shortcuts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.add_rounded,
                label: 'Add New',
                color: AppTheme.primaryYellow,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.people_outline,
                label: 'Customers',
                color: AppTheme.black,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.content_cut_outlined,
                label: 'Services',
                color: AppTheme.black,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.settings_outlined,
                label: 'Settings',
                color: AppTheme.black,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color == AppTheme.primaryYellow
              ? AppTheme.primaryYellow
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: color == AppTheme.primaryYellow
                    ? Colors.black
                    : Colors.black,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
