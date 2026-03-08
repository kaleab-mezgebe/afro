import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/portfolio_stats_card.dart';
import '../widgets/photo_grid.dart';
import '../widgets/recent_reviews_card.dart';

class PortfolioGalleryPage extends ConsumerWidget {
  const PortfolioGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new photo
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter photos
            },
          ),
        ],
      ),
      body: portfolioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Portfolio Statistics
                const PortfolioStatsCard(),

                const SizedBox(height: 16),

                // Photo Grid
                const PhotoGrid(),

                const SizedBox(height: 16),

                // Recent Reviews
                const RecentReviewsCard(),
              ],
            ),
    );
  }
}
