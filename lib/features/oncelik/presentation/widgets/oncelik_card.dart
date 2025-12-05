import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';
import '../../domain/entities/oncelik.dart';
import '../../../../core/config/app_config.dart';

class OncelikCard extends StatelessWidget {
  final Oncelik oncelik;

  const OncelikCard({super.key, required this.oncelik});

  @override
  Widget build(BuildContext context) {
    final formattedDate = AppConfig.dateFormat.format(oncelik.kayitZamani);

    // Hex renk kodunu Color nesnesine dönüştür
    final oncelikRengi = Color(
      int.parse(oncelik.renkKodu.replaceFirst('#', '0xff')),
    );

    return Card(
      color: oncelikRengi,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('general_title')}: ${oncelik.baslik}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context).translate('general_explanation')}: ${oncelik.aciklama}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context).translate('general_colorCode')}: ${oncelik.renkKodu}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context).translate('general_date')}: $formattedDate',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Text(
              '${AppLocalizations.of(context).translate('general_fixed')}: ${oncelik.sabitMi ? AppLocalizations.of(context).translate('general_yes') : AppLocalizations.of(context).translate('general_no')}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
