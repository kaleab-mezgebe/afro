import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../pages/shop_settings_page.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/models/provider_models.dart';

class ShopManagementPage extends ConsumerStatefulWidget {
  const ShopManagementPage({super.key});

  @override
  ConsumerState<ShopManagementPage> createState() => _ShopManagementPageState();
}

class _ShopManagementPageState extends ConsumerState<ShopManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(shopProvider.notifier).loadShops());
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SHOP MANAGEMENT'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            onPressed: () => _showCreateShopDialog(context),
          ),
        ],
      ),
      body: shopState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : shopState.error != null
              ? _buildErrorState(shopState.error!)
              : RefreshIndicator(
                  onRefresh: () => ref.read(shopProvider.notifier).loadShops(),
                  color: AppTheme.primaryYellow,
                  child: shopState.shops.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: shopState.shops.length,
                          itemBuilder: (context, index) {
                            final shop = shopState.shops[index];
                            return _buildShopCard(shop);
                          },
                        ),
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 80, color: Colors.red.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Shops',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: AppTheme.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(shopProvider.notifier).clearError();
              ref.read(shopProvider.notifier).loadShops();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('RETRY'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded,
              size: 80, color: AppTheme.greyMedium.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Shops Found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Build your business ecosystem now',
            style: TextStyle(color: AppTheme.greyMedium),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateShopDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CREATE YOUR FIRST SHOP'),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.greyMedium.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: AppTheme.black, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.greyMedium.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              shop.category.value
                                  .toUpperCase()
                                  .replaceAll('_', ' '),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.greyMedium),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (shop.isActive)
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 14),
                                SizedBox(width: 4),
                                Text('ACTIVE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.green)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppTheme.greyMedium),
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
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit Shop'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(shop.isActive ? Icons.block : Icons.check_circle,
                              size: 16),
                          SizedBox(width: 8),
                          Text(shop.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Shop',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.content_cut_rounded, 'Services', shop),
                _buildQuickAction(Icons.people_outline_rounded, 'Staff', shop),
                _buildQuickAction(Icons.access_time_rounded, 'Hours', shop),
                _buildQuickAction(Icons.settings_outlined, 'Settings', shop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, [Shop? shop]) {
    return InkWell(
      onTap: () {
        // Handle quick actions based on label
        switch (label) {
          case 'Services':
            // Navigate to services management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Services management coming soon')),
            );
            break;
          case 'Staff':
            // Navigate to staff management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Staff management coming soon')),
            );
            break;
          case 'Hours':
            // Navigate to working hours
            if (shop != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShopSettingsPage(),
                ),
              );
            }
            break;
          case 'Settings':
            // Navigate to shop settings
            if (shop != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShopSettingsPage(),
                ),
              );
            }
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.black),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greyMedium)),
          ],
        ),
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, Shop shop) {
    String shopName = shop.name;
    ShopCategory selectedCategory = shop.category;

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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EDIT BUSINESS',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppTheme.greyMedium),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => shopName = v,
                controller: TextEditingController(text: shop.name),
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  hintText: 'e.g. Afro Cuts Premium',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              const Text('SELECT BUSINESS TYPE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greyMedium)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ShopCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryYellow
                            : const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryYellow
                                : Colors.transparent),
                      ),
                      child: Text(
                        cat.value.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (shopName.isNotEmpty) {
                      final updatedShop = Shop(
                        id: shop.id,
                        providerId: shop.providerId,
                        name: shopName,
                        category: selectedCategory,
                        isActive: shop.isActive,
                        rating: shop.rating,
                        totalReviews: shop.totalReviews,
                        createdAt: shop.createdAt,
                        updatedAt: DateTime.now(),
                      );
                      ref.read(shopProvider.notifier).updateShop(updatedShop);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('UPDATE BUSINESS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
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
        content: Text(
            'Are you sure you want to delete "${shop.name}"? This action cannot be undone.'),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CREATE NEW BUSINESS',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppTheme.greyMedium),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => shopName = v,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  hintText: 'e.g. Afro Cuts Premium',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              const Text('SELECT BUSINESS TYPE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greyMedium)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ShopCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryYellow
                            : const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryYellow
                                : Colors.transparent),
                      ),
                      child: Text(
                        cat.value.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (shopName.isNotEmpty) {
                      final newShop = Shop(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        providerId: 'current_user_id', // Would be from auth
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('LAUNCH BUSINESS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
