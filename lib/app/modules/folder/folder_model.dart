class FolderItemModel {
  final int id;
  final String? title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String createdAt;
  final String? createdBy;

  FolderItemModel({
    required this.id,
    this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.createdAt,
    this.createdBy,
  });

  factory FolderItemModel.fromJson(Map<String, dynamic> json) {
    return FolderItemModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
    );
  }

}
