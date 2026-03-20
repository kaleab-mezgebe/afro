import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
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
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 80, color: AppTheme.greyMedium.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Shops Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.black),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: const Icon(Icons.store_rounded, color: AppTheme.black, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.black),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.greyMedium.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              shop.category.value.toUpperCase().replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.greyMedium),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (shop.isActive)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 14),
                                SizedBox(width: 4),
                                Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.greyMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.content_cut_rounded, 'Services'),
                _buildQuickAction(Icons.people_outline_rounded, 'Staff'),
                _buildQuickAction(Icons.access_time_rounded, 'Hours'),
                _buildQuickAction(Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.black),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.greyMedium)),
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CREATE NEW BUSINESS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.greyMedium),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => shopName = v,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  hintText: 'e.g. Afro Cuts Premium',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              const Text('SELECT BUSINESS TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.greyMedium)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ShopCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryYellow : const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.primaryYellow : Colors.transparent),
                      ),
                      child: Text(
                        cat.value.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
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
                      ref.read(shopProvider.notifier).addShop(newShop);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('LAUNCH BUSINESS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
