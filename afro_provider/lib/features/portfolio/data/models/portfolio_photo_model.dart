class PortfolioPhoto {
  final String id;
  final String url;
  final String title;
  final String description;
  final List<String> tags;
  final int likes;
  final DateTime uploadedAt;

  const PortfolioPhoto({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.tags,
    required this.likes,
    required this.uploadedAt,
  });

  PortfolioPhoto copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    List<String>? tags,
    int? likes,
    DateTime? uploadedAt,
  }) {
    return PortfolioPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          title == other.title &&
          description == other.description &&
          tags == other.tags &&
          likes == other.likes &&
          uploadedAt == other.uploadedAt;

  @override
  int get hashCode => Object.hash(id, url, title, description, tags, likes, uploadedAt);
}
