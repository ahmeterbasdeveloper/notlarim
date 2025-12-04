import 'package:flutter/material.dart';

// 🌍 Çoklu dil desteği
import '../../../../core/localization/localization.dart';

// Domain Entity
import '../../domain/entities/durum.dart';

/// 🧩 Her bir “Durum” kaydını kart şeklinde gösterir.
/// Clean Architecture + Çoklu Dil desteği içerir.
class DurumCard extends StatelessWidget {
  final Durum durum;

  const DurumCard({super.key, required this.durum});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      // Renk kodunu güvenli çevir (Örn: #AABBCC -> 0xFFAABBCC)
      final hexCode = durum.renkKodu.replaceAll('#', '');
      color = Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      color = Colors.grey; // Hata olursa varsayılan renk
    }

    final local = AppLocalizations.of(context);

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(6),
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Başlık
            Text(
              '${local.translate('general_title')}: ${durum.baslik}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            /// 🔹 Açıklama
            Text(
              '${local.translate('general_explanation')}: ${durum.aciklama}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            /// 🔹 Renk Kodu
            Text(
              '${local.translate('general_colorCode')}: ${durum.renkKodu}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),

            /// 🔹 Tarih (isteğe bağlı gösterim)
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${local.translate('general_registrationDate')}: '
                '${durum.kayitZamani.toString().split(" ").first}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
