import 'package:flutter/material.dart';
import 'package:notlarim/core/config/app_config.dart';

// 🧩 Domain
import '../../../domain/entities/kontrol_liste.dart';
import '../../../domain/entities/oncelik.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';

// 💾 Data
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';

class KontrolListeCard extends StatelessWidget {
  final KontrolListe kontrolListe;

  const KontrolListeCard({
    super.key,
    required this.kontrolListe,
  });

  @override
  Widget build(BuildContext context) {
    final time = AppConfig.dateFormat.format(kontrolListe.kayitZamani);

    return FutureBuilder<Map<int, Color>>(
      future: _getColorsByPriority(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}');
        } else {
          final renk = snapshot.data?[kontrolListe.oncelikId] ?? Colors.grey;

          return Card(
            color: renk,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Container(
              constraints: const BoxConstraints(minHeight: 150),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📅 Tarih
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 🏷 Başlık
                  Text(
                    kontrolListe.baslik,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // 📝 Açıklama
                  Text(
                    _getShortDescription(kontrolListe.aciklama),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  /// 🔹 Açıklamayı 50 karakterle sınırla
  String _getShortDescription(String text) {
    if (text.length <= 50) return text;
    return '${text.substring(0, 50)}...';
  }

  /// 🔹 Öncelik renklerini getir (UseCase katmanını kullanarak)
  Future<Map<int, Color>> _getColorsByPriority() async {
    final dbHelper = DatabaseHelper.instance; // ✅ DatabaseHelper doğrudan kullanılır
    final repository = OncelikRepositoryImpl(dbHelper);
    final getAllOncelik = GetAllOncelik(repository);

    final List<Oncelik> oncelikler = await getAllOncelik();

    Map<int, Color> colorsByPriority = {};

    for (var oncelik in oncelikler) {
      if (oncelik.id != null && oncelik.renkKodu.isNotEmpty) {
        try {
          final renkHex = oncelik.renkKodu.replaceAll('#', '');
          colorsByPriority[oncelik.id!] =
              Color(int.parse('0xFF$renkHex')).withAlpha(255);
        } catch (e) {
          debugPrint('⚠️ Geçersiz renk kodu: ${oncelik.renkKodu}');
        }
      }
    }

    return colorsByPriority;
  }
}
