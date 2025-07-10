import 'package:flutter/material.dart';
import 'package:leaforia/api_service.dart';
 // Upload fonksiyonu buradaysa

class PredictionScreen extends StatefulWidget {
  final dynamic imageFile; // Galeri veya kamera için seçilen dosya

  const PredictionScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  PredictionResult? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _uploadAndPredict() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String response = await uploadImage(widget.imageFile);
      if (response.isNotEmpty) {
        setState(() {
          _result = PredictionResult.fromJson(response);
        });
      } else {
        setState(() {
          _error = "Tahmin alınamadı.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _uploadAndPredict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tahmin Sonucu")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                : _result != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Tahmin Edilen Hastalık",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _result!.prediction,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Güven Skoru: ${(_result!.confidence * 100).toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Text(
                        "Tahmin bekleniyor...",
                        style: TextStyle(fontSize: 18),
                      ),
      ),
    );
  }
}
