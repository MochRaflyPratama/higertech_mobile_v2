import 'package:get/get.dart';
import 'folder_model.dart';

class FolderProvider extends GetConnect {
  final String baseUrl = 'https://yourapi.com/api';

  Future<List<FolderItemModel>> fetchUploadedFiles() async {
    final response = await get('$baseUrl/files');

    if (response.status.hasError) {
      throw Exception('Failed to load files');
    }

    final List data = response.body;
    return data.map((json) => FolderItemModel.fromJson(json)).toList();
  }
}
