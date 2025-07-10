import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultPage extends StatelessWidget {
  final dynamic image; // Uint8List (Web) veya io.File (Mobil)
  final String prediction;
  final bool isWeb;

  const ResultPage({
    super.key,
    required this.image,
    required this.prediction,
    required this.isWeb,
  });

  // Tahmin edilen sınıf adını daha okunabilir hale çevir
  static const Map<String, String> diseaseNameMap = {
    'Corn___Common_rust': 'Common Rust',
    'Corn___Cercospora_leaf_spot Gray_leaf_spot': 'Cercospora Leaf Spot',
    'Corn___Northern_Leaf_Blight': 'Northern Leaf Blight',
    'Corn___healthy': 'Healthy',
  };

  // Hastalık bilgilerini döndür
  String getDiseaseInfo(String disease) {
    switch (disease) {
      case 'Corn___Common_rust':
        return "Common Rust, mısırda yapraklarda kahverengi ve turuncu kabarcıklar oluşturan bir mantar hastalığıdır. Enfeksiyonun erken tespiti önemlidir.";
      case 'Corn___Cercospora_leaf_spot Gray_leaf_spot':
        return "Cercospora Leaf Spot, mısır yapraklarında gri lekeler ve sararmalar oluşturan yaygın bir yaprak hastalığıdır. Hastalığın ilerlemesini önlemek için uygun ilaçlama gerekir.";
      case 'Corn___Northern_Leaf_Blight':
        return "Northern Leaf Blight, mısırda büyük gri-yeşil yaprak lekeleri yapan, verimi düşüren önemli bir mantar hastalığıdır.";
      case 'Corn___healthy':
        return "Bitki sağlıklı görünüyor. Mısır bitkisinde hastalık belirtisi yok.";
      default:
        return "Hastalık hakkında bilgi mevcut değil.";
    }
  }

  // Uygun şekilde görseli göster
  Widget buildImageWidget() {
    if (image == null) {
      return const Text("Görsel mevcut değil.");
    } else if (isWeb && image is Uint8List) {
      return Image.memory(image, height: 287.5); // 250 * 1.15
    } else if (!isWeb && image is io.File) {
      return Image.file(image, height: 287.5);
    } else {
      return const Text("Görsel gösterilemiyor.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String readableDiseaseName = diseaseNameMap[prediction] ?? prediction;
    final String diseaseInfo = getDiseaseInfo(prediction);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
        backgroundColor: Colors.green[700],
      ),
      body: SafeArea(
        child: Stack(
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
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Transform.scale(
                    scale: 1.15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildImageWidget(),
                          const SizedBox(height: 24),
                          Text(
                            "Hastalık Adı: $readableDiseaseName",
                            style: TextStyle(
                              fontSize: 27.6, // 24 * 1.15
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18.4), // 16 * 1.15
                          Text(
                            diseaseInfo,
                            style: const TextStyle(
                              fontSize: 18.4, // 16 * 1.15
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
