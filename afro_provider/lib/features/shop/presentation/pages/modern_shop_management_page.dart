import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/modern_cards.dart';
import '../../../../core/models/provider_models.dart';
import 'shop_settings_page.dart';

class ModernShopManagementPage extends ConsumerStatefulWidget {
  const ModernShopManagementPage({super.key});

  @override
  ConsumerState<ModernShopManagementPage> createState() => _ModernShopManagementPageState();
}

class _ModernShopManagementPageState extends ConsumerState<ModernShopManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _searchSlideAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: ModernAnimations.medium,
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: ModernAnimations.bounceCurve,
    ));

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: ModernAnimations.smoothCurve,
    ));

    Future.microtask(() {
      ref.read(shopProvider.notifier).loadShops();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: ModernTheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Search
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: ModernTheme.surface,
            elevation: 0,
            expandedHeight: _isSearchExpanded ? 120 : 80,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedSwitcher(
                duration: ModernAnimations.fast,
                child: Text(
                  _isSearchExpanded ? '' : 'Shop Management',
                  key: ValueKey(_isSearchExpanded),
                  style: ModernTheme.headlineMedium,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: ModernTheme.primaryGradient,
                      ),
                    ),
                  ),
                  if (_isSearchExpanded)
                    Container(
                      height: 40,
                      color: ModernTheme.surface,
                    ),
                ],
              ),
            ),
            actions: [
              AnimatedBuilder(
                animation: _searchSlideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _searchSlideAnimation,
                    child: IconButton(
                      icon: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        color: ModernTheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                        });
                        if (_isSearchExpanded) {
                          _searchAnimationController.forward();
                        } else {
                          _searchAnimationController.reverse();
                          _searchController.clear();
                        }
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Bar
          if (_isSearchExpanded)
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _searchSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModernSearchBar(
                    controller: _searchController,
                    hintText: 'Search shops...',
                    onClear: () => _searchController.clear(),
                  ),
                ),
              ),
            ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: ModernTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ModernStatCard(
                          title: 'Total Shops',
                          value: shopState.shops.length.toString(),
                          icon: Icons.store,
                          iconColor: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernStatCard(
                          title: 'Active',
                          value: shopState.shops
                              .where((shop) => shop.isActive)
                              .length
                              .toString(),
                          icon: Icons.check_circle,
                          iconColor: ModernTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Shops List
          if (shopState.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: ModernLoadingIndicator(size: 48),
                ),
              ),
            )
          else if (shopState.error != null)
            SliverToBoxAdapter(
              child: ModernEmptyState(
                title: 'Error Loading Shops',
                subtitle: shopState.error,
                icon: Icons.error_outline,
                action: ModernActionButton(
                  label: 'Retry',
                  icon: Icons.refresh,
                  onPressed: () => ref.read(shopProvider.notifier).loadShops(),
                ),
              ),
            )
          else if (shopState.shops.isEmpty)
            SliverToBoxAdapter(
              child: ModernEmptyState(
                title: 'No Shops Yet',
                subtitle: 'Create your first shop to get started',
                icon: Icons.storefront,
                action: ModernActionButton(
                  label: 'Create Shop',
                  icon: Icons.add,
                  onPressed: () => _showCreateShopDialog(context),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shop = shopState.shops[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildModernShopCard(shop),
                  );
                },
                childCount: shopState.shops.length,
              ),
            ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Modern FAB
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: ModernFab(
          icon: Icons.add_business,
          onPressed: () => _showCreateShopDialog(context),
          tooltip: 'Create Shop',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernShopCard(Shop shop) {
    return ModernGlassCard(
      onTap: () => _showShopDetails(context, shop),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Status
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: ModernTheme.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: ModernTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ModernChip(
                      label: shop.category.value.toUpperCase().replaceAll('_', ' '),
                      selected: shop.isActive,
                      backgroundColor: ModernTheme.surfaceVariant,
                      selectedColor: shop.isActive
                          ? ModernTheme.success
                          : ModernTheme.warning,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: ModernTheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditShopDialog(context, shop);
                      break;
                    case 'toggle_status':
                      _toggleShopStatus(shop);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, shop);
                      break;
                    case 'settings':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopSettingsPage(),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Shop'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          shop.isActive ? Icons.block : Icons.check_circle,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(shop.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 12),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: ModernTheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Delete Shop',
                          style: TextStyle(color: ModernTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                'Rating',
                '${shop.rating.toStringAsFixed(1)}',
                Icons.star,
                ModernTheme.warning,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Reviews',
                shop.totalReviews.toString(),
                Icons.reviews,
                ModernTheme.info,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Status',
                shop.isActive ? 'Active' : 'Inactive',
                shop.isActive ? Icons.check_circle : Icons.block,
                shop.isActive ? ModernTheme.success : ModernTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  Icons.content_cut,
                  'Services',
                  ModernTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  Icons.people,
                  'Staff',
                  ModernTheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  Icons.access_time,
                  'Hours',
                  ModernTheme.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  Icons.analytics,
                  'Analytics',
                  ModernTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: ModernTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: ModernTheme.labelMedium.copyWith(
            color: ModernTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label coming soon'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: ModernTheme.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShopDetails(BuildContext context, Shop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: ModernTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ModernTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: ModernTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  ModernStatCard(
                    title: 'Category',
                    value: shop.category.value.toUpperCase().replaceAll('_', ' '),
                    icon: Icons.category,
                    iconColor: ModernTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ModernActionButton(
                          label: 'Edit',
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditShopDialog(context, shop);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernActionButton(
                          label: 'Settings',
                          icon: Icons.settings,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
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

  void _showCreateShopDialog(BuildContext context) {
    String shopName = '';
    ShopCategory selectedCategory = ShopCategory.barberShop;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: ModernTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREATE NEW SHOP',
                style: ModernTheme.labelMedium.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => shopName = v,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  hintText: 'e.g. Afro Cuts Premium',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SELECT BUSINESS TYPE',
                style: ModernTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ShopCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ModernChip(
                    label: cat.value.toUpperCase().replaceAll('_', ' '),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedCategory = cat);
                      }
                    },
                    selectedColor: ModernTheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ModernActionButton(
                  label: 'Create Shop',
                  icon: Icons.add_business,
                  isFullWidth: true,
                  onPressed: () {
                    if (shopName.isNotEmpty) {
                      final newShop = Shop(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        providerId: 'current_user_id',
                        name: shopName,
                        category: selectedCategory,
                        isActive: true,
                        rating: 0,
                        totalReviews: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      ref.read(shopProvider.notifier).createShop(newShop);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, Shop shop) {
    // Similar to create dialog but with pre-filled data
    _showCreateShopDialog(context);
  }

  void _toggleShopStatus(Shop shop) {
    final updatedShop = Shop(
      id: shop.id,
      providerId: shop.providerId,
      name: shop.name,
      category: shop.category,
      isActive: !shop.isActive,
      rating: shop.rating,
      totalReviews: shop.totalReviews,
      createdAt: shop.createdAt,
      updatedAt: DateTime.now(),
    );
    ref.read(shopProvider.notifier).updateShop(updatedShop);
  }

  void _showDeleteConfirmation(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shop'),
        content: Text('Are you sure you want to delete "${shop.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(shopProvider.notifier).deleteShop(shop.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: ModernTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
