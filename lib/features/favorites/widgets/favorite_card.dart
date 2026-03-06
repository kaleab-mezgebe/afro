import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const FavoriteCard({
    super.key,
    required this.favorite,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Provider image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: favorite['imageUrl'] != null
                      ? Image.network(
                          favorite['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, color: Colors.grey.shade400),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.person, color: Colors.grey.shade400),
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Provider info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider name
                    Text(
                      favorite['name'] ?? 'Unknown Provider',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Specialty
                    Text(
                      favorite['specialty'] ?? 'General Service',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating
                    Row(
                      children: [
                        // Rating stars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (favorite['rating'] as num? ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: index < (favorite['rating'] as num? ?? 0)
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            );
                          }),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Rating number
                        Text(
                          (favorite['rating'] as num? ?? 0).toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
