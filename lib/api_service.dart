import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:html' as html; // sadece web için

class ApiService {
  static const String apiUrl = 'https://leaforia-production.up.railway.app/predict'; //flask api tarafındaki isteğin gönderildiği url

  static Future<Map<String, dynamic>?> uploadImage(dynamic file) async {
    try {
      if (kIsWeb) {
        // Web için dosya gönderimi
        final uri = Uri.parse(apiUrl);
        final request = http.MultipartRequest('POST', uri);

        final reader = html.FileReader();
        final completer = Completer<Uint8List>();

        reader.onLoad.listen((event) {
          completer.complete(reader.result as Uint8List);
        });

        reader.onError.listen((event) {
          completer.completeError('Dosya okuma hatası');
        });

        reader.readAsArrayBuffer(file);

        final bytes = await completer.future;

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'), // veya 'png'
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          print('Sunucu hatası: ${response.statusCode}');
        }
      } else {
        // Mobil için dosya gönderimi
        final uri = Uri.parse(apiUrl);
        final request = http.MultipartRequest('POST', uri);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType('image', 'jpeg'), // veya 'png'
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          print('Sunucu hatası: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('İstek sırasında hata oluştu: $e');
    }

    return null;
  }
}
