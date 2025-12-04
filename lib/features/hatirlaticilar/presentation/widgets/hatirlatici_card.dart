import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';
import 'package:notlarim/core/localization/localization.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_helper.dart';

// Domain Entities
import '../../domain/entities/hatirlatici.dart';

// DI Providers (Veri çekmek için gerekli)
import '../providers/hatirlatici_di_providers.dart';

/// ⚡️ Bu Provider, her kart için ID'leri kullanarak İsimleri ve Rengi çeker.
final hatirlaticiKartProvider =
    FutureProvider.family<Map<String, dynamic>, Hatirlatici>((ref, item) async {
  // UseCase'leri çağırıyoruz
  final getKategori = ref.read(getKategoriByIdProvider);
  final getOncelik = ref.read(getOncelikByIdProvider);

  // Veritabanından verileri çek
  final kategori = await getKategori.call(item.kategoriId);
  final oncelik = await getOncelik.call(item.oncelikId);

  // Renk kodunu işle (Yoksa gri yap)
  Color kartRengi = Colors.white;
  if (oncelik != null && oncelik.renkKodu.isNotEmpty) {
    try {
      kartRengi = ColorHelper.hexToColor(oncelik.renkKodu);
    } catch (_) {
      kartRengi = Colors.grey.shade200;
    }
  }

  return {
    'kategoriAdi': kategori?.baslik ?? 'Silinmiş',
    'oncelikAdi': oncelik?.baslik ?? 'Belirsiz',
    'renk': kartRengi,
  };
});

class HatirlaticiCard extends ConsumerWidget {
  final Hatirlatici hatirlatici;
  final VoidCallback? onTap;

  const HatirlaticiCard({
    super.key,
    required this.hatirlatici,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final dateFormat = AppConfig.dateFormat;

    // Tarihleri formatla
    final kayitZamani = dateFormat.format(hatirlatici.kayitZamani);
    final hatirlatmaZamani =
        dateFormat.format(hatirlatici.hatirlatmaTarihiZamani);

    // ⚡️ Provider'ı izle (Verileri asenkron getir)
    final asyncData = ref.watch(hatirlaticiKartProvider(hatirlatici));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: asyncData.when(
        // ⏳ Yükleniyor...
        loading: () => Card(
          color: Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const SizedBox(
              height: 150, child: Center(child: CircularProgressIndicator())),
        ),

        // ❌ Hata oluştu...
        error: (err, stack) => Card(
          color: Colors.red.shade100,
          child: const SizedBox(
              height: 150, child: Center(child: Icon(Icons.error))),
        ),

        // ✅ Veri geldi!
        data: (data) {
          final String kategoriAdi = data['kategoriAdi'];
          final String oncelikAdi = data['oncelikAdi'];
          final Color kartRengi = data['renk'];

          return Card(
            elevation: 4,
            color: kartRengi, // Öncelik rengini arka plan yaptık
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Üst Bilgiler: Tarih ve Durum
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kayitZamani,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      _buildStatusChip(loc, hatirlatici.durumId),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// 🏷️ Başlık
                  Text(
                    hatirlatici.baslik,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// 📝 Açıklama
                  Text(
                    hatirlatici.aciklama.isNotEmpty
                        ? hatirlatici.aciklama
                        : (loc.translate('general_noDescription') ?? '-'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const Divider(
                      color: Colors.black12, thickness: 1, height: 16),

                  /// ✅ TAŞMA SORUNU ÇÖZÜMÜ: Wrap Kullanımı
                  /// Row yerine Wrap kullanarak sığmayan öğeleri alt satıra atıyoruz.
                  Wrap(
                    spacing: 8.0, // Yatay boşluk
                    runSpacing: 4.0, // Dikey boşluk
                    children: [
                      // Kategori Bilgisi
                      _buildInfoTag(
                        icon: Icons.category_outlined,
                        label: '$kategoriAdi',
                      ),

                      // Öncelik Bilgisi
                      _buildInfoTag(
                        icon: Icons.priority_high,
                        label: '$oncelikAdi',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// ⏰ Hatırlatma Tarihi
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 16, color: Colors.black87),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$hatirlatmaZamani',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Yardımcı Widget: Küçük ikonlu etiketler
  Widget _buildInfoTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Yardımcı Widget: Durum (Aktif/Pasif)
  Widget _buildStatusChip(AppLocalizations loc, int durumId) {
    final isActive = durumId == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade700 : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive
            ? (loc.translate('general_active') ?? 'Aktif')
            : (loc.translate('general_passive') ?? 'Pasif'),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
