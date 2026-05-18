class VideoModel {
  final int id;
  final String title;
  final String description;
  final String coverUrl;
  final String? videoUrl;
  final String category;
  final DateTime? watchedAt; 
  final DateTime createdAt;
  bool isFavorite;
  bool isWatched;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    this.videoUrl,
    required this.category,
    this.watchedAt,
    required this.createdAt,
    this.isFavorite = false,
    this.isWatched = false,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['cover_url'] ?? '',
      videoUrl: map['video_url'],
      category: map['category'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'video_url': videoUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}