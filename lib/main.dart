import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_button/animated_button.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

import 'image_picker_stub.dart'
    if (dart.library.html) 'web_image_picker.dart'
    if (dart.library.io) 'mobile_image_picker.dart';

import 'result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.green,
      ),
      home: const UploadImagePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherInfoWidget extends StatefulWidget {
  const WeatherInfoWidget({super.key});

  @override
  State<WeatherInfoWidget> createState() => _WeatherInfoWidgetState();
}

class _WeatherInfoWidgetState extends State<WeatherInfoWidget> {
  String _weatherInfo = "Yükleniyor...";
  static const String _apiKey = '6e614a0e7022647231305c8d83e9da52';
  static const String _cityName = "Kayseri";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => fetchWeather());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$_cityName&appid=$_apiKey&units=metric&lang=tr',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = (data['main']['temp'] as num).toStringAsFixed(1);
        final desc = data['weather'][0]['description'];
        setState(() {
          _weatherInfo = '$_cityName: $temp°C, $desc';
        });
      } else {
        setState(() {
          _weatherInfo = 'Hava durumu alınamadı (Hata Kodu: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _weatherInfo,
        style: TextStyle(
          color: Colors.green[900],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  dynamic _selectedFile;
  String _fileName = "";
  Uint8List? _webImageBytes;
  bool _isUploading = false;

  Future<void> _selectImage() async {
    final result = await pickImage();
    if (result != null) {
      setState(() {
        _selectedFile = result.file;
        _fileName = result.fileName;
        if (kIsWeb) {
          _webImageBytes = result.bytes;
        }
      });
    }
  }

  Future<void> _uploadImage() async {
    if ((_selectedFile == null && _webImageBytes == null) || _isUploading) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final predictionResult = await uploadImage(_selectedFile, _fileName);

    setState(() {
      _isUploading = false;
    });

    if (predictionResult != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            image: kIsWeb ? _webImageBytes : _selectedFile,
            prediction: predictionResult['prediction'] ?? "Tahmin yok",
            isWeb: kIsWeb,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yükleme başarısız oldu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'assets/arkaplan.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: kIsWeb ? 650 : null, // web için genişlik artırıldı
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Leaforia",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const WeatherInfoWidget(),
                  const SizedBox(height: 30),
                  AnimatedButton(
                    onPressed: _selectImage,
                    child: const Text(
                      "Resim Seç",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    height: 58,
                    width: 220,
                    color: Colors.green[700]!,
                    borderRadius: 16,
                    shadowDegree: ShadowDegree.dark,
                  ),
                  if (_fileName.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Seçilen dosya: $_fileName",
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 18,
                      ),
                    ),
                  ],
                  if (_selectedFile != null || _webImageBytes != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: kIsWeb && _webImageBytes != null
                          ? Image.memory(_webImageBytes!, height: 240)
                          : _selectedFile != null
                              ? Image.file(_selectedFile, height: 240)
                              : const SizedBox(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AnimatedButton(
                    onPressed: _uploadImage,
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            "Hastalığı Bul",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    height: 58,
                    width: 220,
                    color: Colors.teal[700]!,
                    borderRadius: 16,
                    shadowDegree: ShadowDegree.dark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
