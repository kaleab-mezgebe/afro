import 'package:flutter/material.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock photos data
    final photos = [
      {
        'id': '1',
        'url': 'https://picsum.photos/seed/barber1.jpg',
        'title': 'Classic Fade',
        'likes': 45,
      },
      {
        'id': '2',
        'url': 'https://picsum.photos/seed/barber2.jpg',
        'title': 'Beard Design',
        'likes': 32,
      },
      {
        'id': '3',
        'url': 'https://picsum.photos/seed/barber3.jpg',
        'title': 'Modern Cut',
        'likes': 28,
      },
      {
        'id': '4',
        'url': 'https://picsum.photos/seed/barber4.jpg',
        'title': 'Hair Coloring',
        'likes': 56,
      },
      {
        'id': '5',
        'url': 'https://picsum.photos/seed/barber5.jpg',
        'title': 'Wedding Style',
        'likes': 89,
      },
      {
        'id': '6',
        'url': 'https://picsum.photos/seed/barber6.jpg',
        'title': 'Executive Cut',
        'likes': 67,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Work',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return _PhotoItem(
                  url: photo['url'] as String,
                  title: photo['title'] as String,
                  likes: photo['likes'] as int,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final String url;
  final String title;
  final int likes;

  const _PhotoItem({
    required this.url,
    required this.title,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        likes.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
