import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/enhanced_api_client.dart';
import '../../../core/utils/error_handler.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final EnhancedApiClient _api = Get.find<EnhancedApiClient>();
  final TextEditingController _promoCodeCtrl = TextEditingController();

  List<Map<String, dynamic>> _promotions = [];
  bool _isLoading = false;
  bool _isApplying = false;
  Map<String, dynamic>? _appliedPromo;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  @override
  void dispose() {
    _promoCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPromotions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/promotions');
      final data = res.data;
      if (data is List) {
        _promotions = data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['promotions'] is List) {
        _promotions = (data['promotions'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      _promotions = _mockPromotions;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static final List<Map<String, dynamic>> _mockPromotions = [
    {
      'id': 'PROMO-001',
      'code': 'WELCOME20',
      'title': 'Welcome Discount',
      'description': 'Get 20% off your first booking with any specialist.',
      'discountType': 'percentage',
      'discountValue': 20,
      'minOrderAmount': 0,
      'maxDiscount': 100,
      'expiresAt': '2026-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': 1,
      'category': 'new_user',
      'color': 0xFFFFB900,
    },
    {
      'id': 'PROMO-002',
      'code': 'SAVE50',
      'title': 'Flat 50 ETB Off',
      'description': 'Save 50 ETB on any booking above 200 ETB.',
      'discountType': 'fixed',
      'discountValue': 50,
      'minOrderAmount': 200,
      'maxDiscount': 50,
      'expiresAt': '2026-06-30T23:59:59Z',
      'isActive': true,
      'usageLimit': null,
      'category': 'general',
      'color': 0xFF4CAF50,
    },
    {
      'id': 'PROMO-003',
      'code': 'WEEKEND15',
      'title': 'Weekend Special',
      'description': '15% off all bookings on weekends.',
      'discountType': 'percentage',
      'discountValue': 15,
      'minOrderAmount': 100,
      'maxDiscount': 200,
      'expiresAt': '2026-05-31T23:59:59Z',
      'isActive': true,
      'usageLimit': null,
      'category': 'seasonal',
      'color': 0xFF9C27B0,
    },
    {
      'id': 'PROMO-004',
      'code': 'REFER10',
      'title': 'Referral Bonus',
      'description': 'Earn 10% off when you refer a friend who books.',
      'discountType': 'percentage',
      'discountValue': 10,
      'minOrderAmount': 0,
      'maxDiscount': 150,
      'expiresAt': '2026-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': null,
      'category': 'referral',
      'color': 0xFF2196F3,
    },
  ];

  Future<void> _applyPromoCode() async {
    final code = _promoCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ErrorHandler.showErrorSnackbar('Please enter a promo code.');
      return;
    }

    setState(() => _isApplying = true);
    try {
      final res = await _api.post('/promotions/validate', data: {'code': code});
      setState(() => _appliedPromo = res.data as Map<String, dynamic>?);
    } catch (_) {
      // Try mock data
      final found = _mockPromotions.firstWhereOrNull(
        (p) =>
            p['code'].toString().toUpperCase() == code && p['isActive'] == true,
      );
      if (found != null) {
        setState(() => _appliedPromo = found);
        Get.snackbar(
          'Promo Applied!',
          '${found['title']} has been applied.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success,
          colorText: Colors.white,
        );
      } else {
        ErrorHandler.showErrorSnackbar('Invalid or expired promo code.');
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

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
          'Promotions',
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow),
            )
          : RefreshIndicator(
              onRefresh: _loadPromotions,
              color: AppTheme.primaryYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo code input
                    _buildPromoCodeInput(),
                    const SizedBox(height: 32),

                    // Applied promo
                    if (_appliedPromo != null) ...[
                      _buildSectionLabel('APPLIED PROMO'),
                      const SizedBox(height: 12),
                      _buildPromoCard(_appliedPromo!, isApplied: true),
                      const SizedBox(height: 32),
                    ],

                    // Available promotions
                    _buildSectionLabel('AVAILABLE OFFERS'),
                    const SizedBox(height: 12),
                    ..._promotions.map((p) => _buildPromoCard(p)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPromoCodeInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a promo code?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your code below to get a discount',
            style: TextStyle(fontSize: 13, color: AppTheme.grey500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCodeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. WELCOME20',
                    hintStyle: TextStyle(
                      color: AppTheme.grey400,
                      letterSpacing: 1,
                    ),
                    filled: true,
                    fillColor: AppTheme.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.grey200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.grey200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryYellow,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isApplying ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Apply',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppTheme.greyMedium,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo, {bool isApplied = false}) {
    final color = Color(promo['color'] as int? ?? 0xFFFFB900);
    final discountType = promo['discountType'] as String? ?? 'percentage';
    final discountValue = promo['discountValue'] as num? ?? 0;
    final expiresAt = promo['expiresAt'];
    final isThisApplied = _appliedPromo?['id'] == promo['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: isThisApplied
            ? Border.all(color: AppTheme.primaryYellow, width: 2)
            : null,
        boxShadow: [AppTheme.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Color accent
            Container(width: 8, height: 120, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            promo['title'] ?? 'Promotion',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            discountType == 'percentage'
                                ? '$discountValue% OFF'
                                : '$discountValue ETB OFF',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promo['description'] ?? '',
                      style: TextStyle(fontSize: 13, color: AppTheme.grey600),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Code chip with copy
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: promo['code'] ?? ''),
                            );
                            Get.snackbar(
                              'Copied!',
                              'Code ${promo['code']} copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.grey50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.grey200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  promo['code'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: AppTheme.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: AppTheme.grey500,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (expiresAt != null)
                          Text(
                            'Expires ${_formatDate(expiresAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.grey400,
                            ),
                          ),
                      ],
                    ),
                    if (isThisApplied) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Applied',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                setState(() => _appliedPromo = null),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _promoCodeCtrl.text = promo['code'] ?? '';
                            _applyPromoCode();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Apply This Code',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
