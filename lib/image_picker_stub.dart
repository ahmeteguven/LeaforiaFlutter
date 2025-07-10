import 'dart:typed_data';

class ImageResult {
  final dynamic file;
  final String fileName;
  final Uint8List? bytes;

  ImageResult({
    required this.file,
    required this.fileName,
    this.bytes,
  });
}

Future<ImageResult?> pickImage() async {
  return null;
}

Future<Map<String, dynamic>?> uploadImage(dynamic file, String fileName) async {
  return null;
}
