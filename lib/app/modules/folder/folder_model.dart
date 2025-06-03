class FolderItemModel {
  final int id;
  final String fileName;
  final String url;
  final String uploadedAt;

  FolderItemModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
  });

  factory FolderItemModel.fromJson(Map<String, dynamic> json) {
    return FolderItemModel(
      id: json['id'],
      fileName: json['file_name'],
      url: json['url'],
      uploadedAt: json['uploaded_at'],
    );
  }
}
