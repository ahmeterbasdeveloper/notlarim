import 'package:flutter/material.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/localization/localization.dart';
import '../../../core/config/app_config.dart';

/// 🔹 Öncelik seviyelerine göre renk paleti
final List<Color> _priorityColors = [
  Colors.green.shade200, // 0 - Düşük
  Colors.lightBlue.shade200, // 1 - Orta
  Colors.orange.shade300, // 2 - Yüksek
  Colors.purple.shade300, // 3 - Çok Yüksek
  Colors.red.shade400, // 4 - Acil
];

/// 💡 Hatırlatıcı kart bileşeni — liste ekranında her hatırlatıcıyı temsil eder.
class HatirlaticiCard extends StatelessWidget {
  final Hatirlatici hatirlatici;
  final VoidCallback? onTap;

  const HatirlaticiCard({
    super.key,
    required this.hatirlatici,
    this.onTap,
  });

  /// 🔸 Öncelik rengine göre kartın arka planı
  Color _getPriorityColor() {
    final index = hatirlatici.oncelikId.clamp(0, _priorityColors.length - 1);
    return _priorityColors[index];
  }

  /// 🔸 Durum (aktif / pasif) etiketi
  Widget _buildStatusChip(AppLocalizations loc) {
    final isActive = hatirlatici.durumId == 1;
    return Chip(
      backgroundColor: isActive ? Colors.green.shade700 : Colors.grey.shade600,
      label: Text(
        isActive
            ? loc.translate('general_active')
            : loc.translate('general_passive'),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dateFormat = AppConfig.dateFormat;
    final kayitZamani = dateFormat.format(hatirlatici.kayitZamani);
    final hatirlatmaZamani =
        dateFormat.format(hatirlatici.hatirlatmaTarihiZamani);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.black12,
      child: Card(
        elevation: 4,
        color: _getPriorityColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Üst Bilgiler: Kayıt tarihi + Durum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    kayitZamani,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  _buildStatusChip(loc),
                ],
              ),
              const SizedBox(height: 8),

              /// 🏷️ Başlık
              Text(
                hatirlatici.baslik,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              /// 📝 Açıklama
              Text(
                hatirlatici.aciklama.isNotEmpty
                    ? (hatirlatici.aciklama.length <= 100
                        ? hatirlatici.aciklama
                        : '${hatirlatici.aciklama.substring(0, 100)}...')
                    : loc.translate('general_noDescription'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              /// 🔹 Alt Bilgi (Kategori - Öncelik - Hatırlatma Tarihi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category_outlined,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${loc.translate('general_category')}: ${hatirlatici.kategoriId}',
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.priority_high,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${loc.translate('general_priority')}: ${hatirlatici.oncelikId}',
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// ⏰ Hatırlatma Tarihi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        loc.translate('general_reminderDate'),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    hatirlatmaZamani,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
