import 'package:flutter/material.dart';

class RecentReviewsCard extends StatelessWidget {
  const RecentReviewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock reviews data
    final reviews = [
      {
        'customerName': 'John Smith',
        'rating': 5.0,
        'comment': 'Amazing haircut! Sarah always does a great job.',
        'date': '2 days ago',
      },
      {
        'customerName': 'Mike Wilson',
        'rating': 4.5,
        'comment': 'Good service, but could be faster.',
        'date': '5 days ago',
      },
      {
        'customerName': 'Emily Davis',
        'rating': 4.8,
        'comment': 'Perfect beard trim! Very professional.',
        'date': '1 week ago',
      },
      {
        'customerName': 'Robert Johnson',
        'rating': 5.0,
        'comment': 'Best haircut I\'ve ever had! Highly recommend.',
        'date': '2 weeks ago',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...reviews
                .map((review) => _ReviewItem(
                      customerName: review['customerName'] as String,
                      rating: review['rating'] as double,
                      comment: review['comment'] as String,
                      date: review['date'] as String,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String customerName;
  final double rating;
  final String comment;
  final String date;

  const _ReviewItem({
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(
                  customerName
                      .split(' ')
                      .map((name) => name[0])
                      .join('')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                              5,
                              (index) => Icon(
                                    Icons.star,
                                    color: index < rating
                                        ? Colors.amber
                                        : Colors.grey[300],
                                    size: 16,
                                  )),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
