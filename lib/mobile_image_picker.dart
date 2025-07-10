// mobile_image_picker.dart
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ImageResult {
  final io.File file;
  final String fileName;
  final Uint8List? bytes; // Ortaklık için var, mobilde kullanılmıyor

  ImageResult({
    required this.file,
    required this.fileName,
    this.bytes,
  });
}

Future<ImageResult?> pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final file = io.File(pickedFile.path);
    return ImageResult(file: file, fileName: pickedFile.name);
  }
  return null;
}

Future<Map<String, dynamic>?> uploadImage(dynamic file, String fileName) async {
  final url = Uri.parse('https://leaforia-production.up.railway.app/predict');

  io.HttpClient client = io.HttpClient()
    ..badCertificateCallback = (io.X509Certificate cert, String host, int port) => true;

  IOClient ioClient = IOClient(client);

  try {
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    var streamedResponse = await ioClient.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      print('Sunucu hatası: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Upload failed: $e');
    return null;
  }
}
