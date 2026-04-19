import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/barber_api_service.dart';
import '../../../core/services/service_api_service.dart';
import '../../../core/services/review_api_service.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_empty_state.dart';
import 'package:customer_app/features/appointments/controllers/appointments_controller.dart';

class PortfolioPage extends StatefulWidget {
  final Map<String, dynamic>? specialist;
  const PortfolioPage({super.key, required this.specialist});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  final BarberApiService _barberService = Get.find<BarberApiService>();
  final ServiceApiService _serviceService = Get.find<ServiceApiService>();
  final ReviewApiService _reviewService = Get.find<ReviewApiService>();

  late TabController _tabController;
  final Set<int> _selectedIndices = {};
  bool _isFavorite = false;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _reviews = [];
  List<String> _portfolioImages = [];

  static const _yellow = AppTheme.primaryYellow;
  static const _yellowPale = Color(0xFFFFF8E1);
  static const _bg = Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBarberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _imageUrl {
    final s = widget.specialist;
    if (s == null) return '';
    return s['image']?.toString() ??
        s['imageUrl']?.toString() ??
        s['profileImage']?.toString() ??
        '';
  }

  // Backend returns price as decimal dollars directly (e.g. 15.00)
  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _loadBarberData() async {
    if (widget.specialist == null) {
      setState(() {
        _error = 'No specialist data';
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final barberId = widget.specialist!['id']?.toString() ?? '';
    if (barberId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      List<Map<String, dynamic>> services = [];
      List<Map<String, dynamic>> reviews = [];
      List<String> portfolioImages = [];

      try {
        final raw = await _serviceService.getServicesByBarber(barberId);
        services = raw.cast<Map<String, dynamic>>();
      } catch (_) {
        try {
          final all = await _serviceService.getServices();
          services = all
              .cast<Map<String, dynamic>>()
              .where(
                (s) =>
                    s['barberId']?.toString() == barberId ||
                    s['barber_id']?.toString() == barberId,
              )
              .toList();
        } catch (_) {}
      }

      try {
        final details = await _barberService.getBarber(barberId);
        final rawImages = details['portfolioImages'];
        if (rawImages is List) {
          portfolioImages = rawImages
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}

      try {
        final raw = await _reviewService.getBarberReviews(barberId, limit: 10);
        reviews = raw.cast<Map<String, dynamic>>();
      } catch (_) {}

      setState(() {
        _services = services;
        _reviews = reviews;
        _portfolioImages = portfolioImages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(child: AppLoading()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Error',
            message: _error!,
            actionText: 'Retry',
            onAction: _loadBarberData,
          ),
        ),
      );
    }

    final controller = Get.find<AppointmentsController>();
    final name = widget.specialist?['name']?.toString() ?? 'Specialist';
    final rating = (widget.specialist?['rating'] as num?)?.toDouble() ?? 0.0;
    final address =
        widget.specialist?['address']?.toString() ??
        widget.specialist?['location']?.toString() ??
        '';
    final categories = widget.specialist?['categories'];
    final String specialty = (categories is List && categories.isNotEmpty)
        ? categories.first.toString()
        : 'Hair Specialist';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildHero(name, rating, specialty, address),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildStatsRow(rating),
                      _buildTabBar(),
                      _buildTabContent(controller),
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedIndices.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBookBar(controller),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    String name,
    double rating,
    String specialty,
    String address,
  ) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isFavorite ? _yellow : Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            _imageUrl.isNotEmpty
                ? Image.network(
                    _imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderBg(),
                  )
                : _placeholderBg(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1.0],
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: _yellow,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBg() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
      ),
    ),
    child: const Center(
      child: Icon(Icons.person_rounded, size: 100, color: Colors.white12),
    ),
  );

  Widget _buildStatsRow(double rating) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _stat(
            Icons.star_rounded,
            _yellow,
            rating.toStringAsFixed(1),
            'Rating',
          ),
          _divider(),
          _stat(
            Icons.rate_review_rounded,
            AppTheme.grey500,
            _reviews.length.toString(),
            'Reviews',
          ),
          _divider(),
          _stat(
            Icons.content_cut_rounded,
            AppTheme.grey500,
            _services.length.toString(),
            'Services',
          ),
          _divider(),
          _stat(
            Icons.photo_library_rounded,
            AppTheme.grey500,
            _portfolioImages.length.toString(),
            'Photos',
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color == _yellow ? _yellowPale : AppTheme.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 44, color: AppTheme.grey200);

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _yellow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _yellow.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: AppTheme.grey500,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Services'),
          Tab(text: 'Portfolio'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppointmentsController controller) {
    final servicesH = _services.isEmpty
        ? 140.0
        : (_services.length * 112.0).clamp(140.0, 700.0);
    final portfolioH = _portfolioImages.isEmpty ? 140.0 : 420.0;
    final reviewsH = _reviews.isEmpty
        ? 140.0
        : (_reviews.length * 120.0).clamp(140.0, 700.0);
    final height =
        [servicesH, portfolioH, reviewsH].reduce((a, b) => a > b ? a : b) + 32;
    return SizedBox(
      height: height,
      child: TabBarView(
        controller: _tabController,
        children: [_servicesTab(), _portfolioTab(), _reviewsTab()],
      ),
    );
  }

  Widget _servicesTab() {
    if (_services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.content_cut_rounded,
                size: 48,
                color: AppTheme.grey300,
              ),
              const SizedBox(height: 12),
              const Text(
                'No services listed yet',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final svc = _services[index];
        final isSelected = _selectedIndices.contains(index);
        final svcName = svc['name']?.toString() ?? 'Service';
        // price comes from DB as decimal dollars e.g. "15.00"
        final price = double.tryParse(svc['price']?.toString() ?? '0') ?? 0.0;
        final duration = svc['durationMinutes']?.toString() ?? '30';
        final description = svc['description']?.toString() ?? '';

        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected)
              _selectedIndices.remove(index);
            else
              _selectedIndices.add(index);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Light yellow tint when selected — text always readable
              color: isSelected ? _yellowPale : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? _yellow : AppTheme.grey200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _yellow.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? _yellow : AppTheme.grey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.content_cut_rounded,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svcName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppTheme.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_fmt(price)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _yellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Added',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _portfolioTab() {
    if (_portfolioImages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 48,
                color: AppTheme.grey300,
              ),
              const SizedBox(height: 12),
              const Text(
                'No portfolio photos yet',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _portfolioImages.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _portfolioImages[index],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppTheme.grey100,
            child: const Icon(
              Icons.image_rounded,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewsTab() {
    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rate_review_rounded,
                size: 48,
                color: AppTheme.grey300,
              ),
              const SizedBox(height: 12),
              const Text(
                'No reviews yet',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final reviewerName =
            review['customerName']?.toString() ??
            review['userName']?.toString() ??
            'Anonymous';
        final comment = review['comment']?.toString() ?? '';
        final ratingVal = (review['rating'] as num?)?.toInt() ?? 0;
        final initials = reviewerName
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _yellowPale,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'A' : initials,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reviewerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < ratingVal
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 14,
                              color: _yellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        comment,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.grey700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookBar(AppointmentsController controller) {
    final selected = _selectedIndices.map((i) => _services[i]).toList();
    final totalPrice = selected.fold(
      0.0,
      (sum, s) => sum + (double.tryParse(s['price']?.toString() ?? '0') ?? 0.0),
    );
    final totalDuration = selected.fold(
      0,
      (sum, s) =>
          sum + (int.tryParse(s['durationMinutes']?.toString() ?? '0') ?? 0),
    );
    final count = selected.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _yellowPale,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.content_cut_rounded,
                          color: _yellow,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          count == 1
                              ? selected.first['name']?.toString() ?? 'Service'
                              : '$count services selected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: AppTheme.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalDuration min total',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${_fmt(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'total',
                        style: TextStyle(fontSize: 11, color: AppTheme.grey500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (widget.specialist != null && selected.isNotEmpty) {
                    controller.startBookingFromPortfolio(
                      widget.specialist!,
                      selected,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _yellow,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _yellow.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: Colors.black,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
