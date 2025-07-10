// web_image_picker.dart
import 'dart:async'; 
import 'dart:convert';
import 'dart:html' as html;
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
  final completer = Completer<ImageResult?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) async {
    final file = uploadInput.files?.first;
    if (file != null) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final result = reader.result;

      Uint8List bytes;

      if (result is ByteBuffer) {
        bytes = result.asUint8List();
      } else if (result is Uint8List) {
        bytes = result;
      } else {
        completer.complete(null);
        return;
      }

      completer.complete(ImageResult(file: file, fileName: file.name, bytes: bytes));
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}

Future<Map<String, dynamic>?> uploadImage(dynamic file, String fileName) async {
  final url = 'https://leaforia-production.up.railway.app/predict';

  final formData = html.FormData();
  formData.appendBlob('image', file, fileName);

  final request = html.HttpRequest();
  final completer = Completer<Map<String, dynamic>?>();

  request.open('POST', url);
  request.send(formData);

  request.onLoadEnd.listen((event) {
    if (request.status == 200) {
      final data = jsonDecode(request.responseText!);
      completer.complete(data);
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
