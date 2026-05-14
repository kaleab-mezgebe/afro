import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

/// Modern analytics dashboard for provider performance
class AnalyticsDashboard extends StatelessWidget {
  final AnalyticsData data;
  final String? period;

  const AnalyticsDashboard({
    super.key,
    required this.data,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: ModernTheme.headlineLarge.copyWith(fontSize: 28),
                  ),
                  if (period != null)
                    Text(
                      period!,
                      style: ModernTheme.bodyMedium.copyWith(
                        color: ModernTheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              _PeriodSelector(
                selectedPeriod: period ?? 'This Month',
                onPeriodChanged: (period) {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Key Metrics Grid
          _MetricsGrid(data: data),
          const SizedBox(height: 24),

          // Revenue Chart
          _RevenueCard(data: data),
          const SizedBox(height: 24),

          // Bookings Chart
          _BookingsCard(data: data),
          const SizedBox(height: 24),

          // Performance Cards Row
          Row(
            children: [
              Expanded(
                child: _PerformanceCard(
                  title: 'Top Services',
                  items: data.topServices,
                  icon: Icons.star_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PerformanceCard(
                  title: 'Peak Hours',
                  items: data.peakHours,
                  icon: Icons.access_time_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Team Performance
          _TeamPerformanceCard(data: data),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final AnalyticsData data;

  const _MetricsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          title: 'Total Revenue',
          value: '\$${data.totalRevenue.toStringAsFixed(0)}',
          change: data.revenueChange,
          icon: Icons.attach_money_rounded,
          color: ModernTheme.success,
        ),
        _MetricCard(
          title: 'Total Bookings',
          value: data.totalBookings.toString(),
          change: data.bookingsChange,
          icon: Icons.calendar_today_rounded,
          color: ModernTheme.primary,
        ),
        _MetricCard(
          title: 'New Clients',
          value: data.newClients.toString(),
          change: data.clientsChange,
          icon: Icons.person_add_rounded,
          color: ModernTheme.secondary,
        ),
        _MetricCard(
          title: 'Avg. Rating',
          value: data.averageRating.toStringAsFixed(1),
          change: data.ratingChange,
          icon: Icons.star_rounded,
          color: const Color(0xFFFFA000),
          isRating: true,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isRating;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? ModernTheme.success.withValues(alpha: 0.1)
                      : ModernTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? ModernTheme.success : ModernTheme.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change.replaceAll('+', '').replaceAll('-', ''),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? ModernTheme.success : ModernTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: ModernTheme.labelMedium.copyWith(
              color: ModernTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ModernTheme.headlineMedium.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final AnalyticsData data;

  const _RevenueCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Trend',
                style: ModernTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last 7 days',
                  style: ModernTheme.labelMedium.copyWith(
                    color: ModernTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _RevenueChart(data: data.revenueData),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<RevenueDataPoint> data;

  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _RevenueChartPainter(data: data, maxValue: maxValue),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<RevenueDataPoint> data;
  final double maxValue;

  _RevenueChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ModernTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = ModernTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final width = size.width / (data.length - 1);
    final height = size.height - 40;

    for (int i = 0; i < data.length; i++) {
      final x = i * width;
      final y = height - (data[i].value / maxValue) * height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = ModernTheme.primary..style = PaintingStyle.fill,
      );
    }

    fillPath.lineTo(size.width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(fillPath, fillPaint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      if (i % 2 == 0) {
        textPainter.text = TextSpan(
          text: data[i].label,
          style: ModernTheme.labelMedium.copyWith(
            color: ModernTheme.onSurfaceVariant,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(i * width - textPainter.width / 2, size.height - 15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BookingsCard extends StatelessWidget {
  final AnalyticsData data;

  const _BookingsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings Overview',
            style: ModernTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BookingStat(
                  label: 'Confirmed',
                  value: data.confirmedBookings,
                  color: ModernTheme.success,
                  total: data.totalBookings,
                ),
              ),
              Expanded(
                child: _BookingStat(
                  label: 'Pending',
                  value: data.pendingBookings,
                  color: ModernTheme.warning,
                  total: data.totalBookings,
                ),
              ),
              Expanded(
                child: _BookingStat(
                  label: 'Cancelled',
                  value: data.cancelledBookings,
                  color: ModernTheme.error,
                  total: data.totalBookings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final int total;

  const _BookingStat({
    required this.label,
    required this.value,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: ModernTheme.labelMedium.copyWith(
            color: ModernTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: ModernTheme.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final List<PerformanceItem> items;
  final IconData icon;

  const _PerformanceCard({
    required this.title,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ModernTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: ModernTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.take(3).map((item) => _PerformanceItemTile(item: item)),
        ],
      ),
    );
  }
}

class _PerformanceItemTile extends StatelessWidget {
  final PerformanceItem item;

  const _PerformanceItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: ModernTheme.bodyMedium,
            ),
          ),
          Container(
            width: (item.value * 100).clamp(0.0, 100.0),
            height: 6,
            decoration: BoxDecoration(
              color: ModernTheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(item.value * 100).round()}%',
              style: ModernTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPerformanceCard extends StatelessWidget {
  final AnalyticsData data;

  const _TeamPerformanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Performance',
            style: ModernTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ...data.teamPerformance.map((member) => _TeamMemberTile(member: member)),
        ],
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  final TeamMember member;

  const _TeamMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(member.avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: ModernTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${member.bookings} bookings • \$${member.revenue.toStringAsFixed(0)}',
                  style: ModernTheme.labelMedium.copyWith(
                    color: ModernTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ModernTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: ModernTheme.success),
                const SizedBox(width: 4),
                Text(
                  member.rating.toStringAsFixed(1),
                  style: ModernTheme.labelMedium.copyWith(
                    color: ModernTheme.success,
                    fontWeight: FontWeight.w700,
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

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            label: 'Today',
            isSelected: selectedPeriod == 'Today',
            onTap: () => onPeriodChanged('Today'),
          ),
          _PeriodChip(
            label: 'This Week',
            isSelected: selectedPeriod == 'This Week',
            onTap: () => onPeriodChanged('This Week'),
          ),
          _PeriodChip(
            label: 'This Month',
            isSelected: selectedPeriod == 'This Month',
            onTap: () => onPeriodChanged('This Month'),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ModernTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: ModernTheme.labelMedium.copyWith(
            color: isSelected ? ModernTheme.onSurface : ModernTheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Data Models
class AnalyticsData {
  final double totalRevenue;
  final String revenueChange;
  final int totalBookings;
  final String bookingsChange;
  final int newClients;
  final String clientsChange;
  final double averageRating;
  final String ratingChange;
  final List<RevenueDataPoint> revenueData;
  final int confirmedBookings;
  final int pendingBookings;
  final int cancelledBookings;
  final List<PerformanceItem> topServices;
  final List<PerformanceItem> peakHours;
  final List<TeamMember> teamPerformance;

  const AnalyticsData({
    required this.totalRevenue,
    required this.revenueChange,
    required this.totalBookings,
    required this.bookingsChange,
    required this.newClients,
    required this.clientsChange,
    required this.averageRating,
    required this.ratingChange,
    required this.revenueData,
    required this.confirmedBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
    required this.topServices,
    required this.peakHours,
    required this.teamPerformance,
  });
}

class RevenueDataPoint {
  final String label;
  final double value;

  const RevenueDataPoint({required this.label, required this.value});
}

class PerformanceItem {
  final String name;
  final double value; // 0.0 to 1.0

  const PerformanceItem({required this.name, required this.value});
}

class TeamMember {
  final String name;
  final String avatar;
  final int bookings;
  final double revenue;
  final double rating;

  const TeamMember({
    required this.name,
    required this.avatar,
    required this.bookings,
    required this.revenue,
    required this.rating,
  });
}
