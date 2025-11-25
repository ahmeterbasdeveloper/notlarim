import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import '../../../../domain/entities/kategori.dart';

/// 🧩 Kategori kartı — Clean Architecture uyumlu.
/// Domain entity [Kategori] ile çalışır.
class KategoriCard extends StatelessWidget {
  final Kategori kategori;

  const KategoriCard({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    // Renk kodunu güvenli şekilde parse etme
    Color kategoriRengi;
    try {
      kategoriRengi =
          Color(int.parse(kategori.renkKodu.replaceFirst('#', '0xff')));
    } catch (e) {
      kategoriRengi = Colors.grey; // Hatalı renk kodu için fallback
    }

    final local = AppLocalizations.of(context);

    return Card(
      color: kategoriRengi.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${local.translate('general_title')}: ${kategori.baslik}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${local.translate('general_explanation')}: ${kategori.aciklama}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${local.translate('general_colorCode')}: ${kategori.renkKodu}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
