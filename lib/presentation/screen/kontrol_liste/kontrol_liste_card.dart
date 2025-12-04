import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod Eklendi
import '../../../../core/config/app_config.dart';
import '../../../domain/entities/kontrol_liste.dart';

// 🔌 Provider Importu
import 'providers/kontrol_liste_providers.dart';

class KontrolListeCard extends ConsumerWidget {
  final KontrolListe kontrolListe;

  const KontrolListeCard({
    super.key,
    required this.kontrolListe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = AppConfig.dateFormat.format(kontrolListe.kayitZamani);

    // 🔄 Provider'ı izliyoruz.
    // oncelikId parametresini göndererek rengi asenkron olarak istiyoruz.
    final colorAsyncValue =
        ref.watch(oncelikColorProvider(kontrolListe.oncelikId));

    return colorAsyncValue.when(
      // ⏳ Yükleniyor durumu (Hafif gri bir kart göster)
      loading: () => _buildCardContent(
          color: Colors.grey.shade100, time: time, isLoading: true),

      // ❌ Hata durumu (Varsayılan gri renk)
      error: (err, stack) =>
          _buildCardContent(color: Colors.grey.shade300, time: time),

      // ✅ Veri geldi (Gerçek rengi kullan)
      data: (color) => _buildCardContent(color: color, time: time),
    );
  }

  /// 🎨 Kart Tasarımı (Kod tekrarını önlemek için ayrıldı)
  Widget _buildCardContent({
    required Color color,
    required String time,
    bool isLoading = false,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(12),
        child: isLoading
            ? const Center(
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : Column(
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

  /// 🔹 Açıklamayı 50 karakterle sınırla
  String _getShortDescription(String text) {
    if (text.length <= 50) return text;
    return '${text.substring(0, 50)}...';
  }
}
