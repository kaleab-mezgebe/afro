import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/portfolio_photo_model.dart';
import '../../data/models/review_model.dart';
import '../../../../core/di/injection_container.dart';

// Portfolio State
class PortfolioState {
  final bool isLoading;
  final String? error;
  final List<PortfolioPhoto> photos;
  final List<Review> reviews;

  const PortfolioState({
    this.isLoading = false,
    this.error,
    this.photos = const [],
    this.reviews = const [],
  });

  PortfolioState copyWith({
    bool? isLoading,
    String? error,
    List<PortfolioPhoto>? photos,
    List<Review>? reviews,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      photos: photos ?? this.photos,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          photos == other.photos &&
          reviews == other.reviews;

  @override
  int get hashCode => Object.hash(isLoading, error, photos, reviews);
}

// Portfolio Notifier
class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier() : super(const PortfolioState());

  Future<void> loadPortfolio() async {
    state = const PortfolioState(isLoading: true);

    try {
      // Get shop ID from provider service (assuming first shop)
      final shops = await shopService.getShops();
      if (shops.isEmpty) {
        state = const PortfolioState(
          isLoading: false,
          error: 'No shop found. Please create a shop first.',
          photos: [],
          reviews: [],
        );
        return;
      }

      final shopId = shops[0]['id'].toString();

      // Fetch portfolio photos and reviews from API
      final photosResponse = await portfolioService.getPortfolioPhotos(shopId);
      final reviewsResponse = await portfolioService.getShopReviews(shopId);

      // Convert API response to models
      final photos = photosResponse.map((json) {
        return PortfolioPhoto(
          id: json['id'].toString(),
          url: json['url'] ?? '',
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          tags:
              (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
          likes: json['likes'] ?? 0,
          uploadedAt: DateTime.parse(json['uploadedAt'] ?? json['createdAt']),
        );
      }).toList();

      final reviews = reviewsResponse.map((json) {
        return Review(
          id: json['id'].toString(),
          customerName: json['customerName'] ?? 'Anonymous',
          rating: (json['rating'] ?? 0).toDouble(),
          comment: json['comment'] ?? '',
          createdAt: DateTime.parse(json['createdAt']),
        );
      }).toList();

      state = PortfolioState(
        isLoading: false,
        photos: photos,
        reviews: reviews,
        error: null,
      );
    } catch (e) {
      state = PortfolioState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void addPhoto(PortfolioPhoto photo) {
    final currentPhotos = List<PortfolioPhoto>.from(state.photos);
    currentPhotos.add(photo);
    state = state.copyWith(photos: currentPhotos);
  }

  void deletePhoto(String photoId) {
    final currentPhotos =
        state.photos.where((photo) => photo.id != photoId).toList();
    state = state.copyWith(photos: currentPhotos);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>(
  (ref) => PortfolioNotifier(),
);
