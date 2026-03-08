import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/portfolio_photo_model.dart';
import '../../data/models/review_model.dart';

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      final mockPhotos = [
        PortfolioPhoto(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          title: 'Classic Fade',
          description: 'Perfect fade for modern look',
          tags: ['Men', 'Fade', 'Classic'],
          likes: 45,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PortfolioPhoto(
          id: '2',
          url: 'https://example.com/photo2.jpg',
          title: 'Beard Design',
          description: 'Professional beard trimming',
          tags: ['Beard', 'Men', 'Professional'],
          likes: 32,
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      final mockReviews = [
        Review(
          id: '1',
          customerName: 'John Smith',
          rating: 5.0,
          comment: 'Amazing haircut! Sarah always does a great job.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: '2',
          customerName: 'Mike Wilson',
          rating: 4.5,
          comment: 'Good service, but could be faster.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      state = PortfolioState(
        isLoading: false,
        photos: mockPhotos,
        reviews: mockReviews,
      );
    } catch (e) {
      state = PortfolioState(error: e.toString());
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
