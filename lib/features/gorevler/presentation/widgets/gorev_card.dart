import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';
import '../../../../../core/config/app_config.dart';
import '../../domain/entities/gorev.dart';

class GorevCard extends StatelessWidget {
  final Gorev gorev;

  const GorevCard({super.key, required this.gorev});

  Color _getPriorityColor(int oncelikId) {
    const colorsByPriority = [
      Color(0xFFFFB74D),
      Color(0xFF81C784),
      Color(0xFF64B5F6),
      Color(0xFFBA68C8),
      Color(0xFFE57373),
    ];
    final index = oncelikId.clamp(0, colorsByPriority.length - 1);
    return colorsByPriority[index];
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final kayitZamani = AppConfig.dateFormat.format(gorev.kayitZamani);
    final baslama = AppConfig.dateFormat.format(gorev.baslamaTarihiZamani);
    final bitis = AppConfig.dateFormat.format(gorev.bitisTarihiZamani);

    return Card(
      color: _getPriorityColor(gorev.oncelikId),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kayitZamani,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gorev.baslik,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              gorev.aciklama.length > 80
                  ? '${gorev.aciklama.substring(0, 80)}...'
                  : gorev.aciklama,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${local.translate('general_startingDate')}: $baslama',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${local.translate('general_endDate')}: $bitis',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
