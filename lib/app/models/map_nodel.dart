class MapPoint {
  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? createdBy;
  final DateTime? createdAt;

  MapPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.createdBy,
    this.createdAt,
  });

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl']as String?,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
