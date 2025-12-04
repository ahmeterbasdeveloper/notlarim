import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod eklendi
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/color_helper.dart';

// 🧠 Domain
import '../../domain/entities/not.dart';

// 🔌 DI Providers (Generic UseCase'lere erişim için)
import '../providers/not_di_providers.dart';

/// ⚡️ 1. Kartın verilerini (Kategori, Öncelik, Renk) asenkron getiren Provider
/// Bu provider, her 'Not' nesnesi için özel çalışır (family kullanımı).
final notCardDataProvider =
    FutureProvider.family<Map<String, dynamic>, Not>((ref, not) async {
  // AppProviders dosyasındaki Generic UseCase provider'larını okuyoruz
  final getKategori = ref.read(getKategoriByIdProvider);
  final getOncelik = ref.read(getOncelikByIdProvider);

  // Verileri çekiyoruz
  final kategori = await getKategori.call(not.kategoriId);
  final oncelik = await getOncelik.call(not.oncelikId);

  // Rengi hesaplıyoruz
  final color = ColorHelper.hexToColor(oncelik?.renkKodu ?? '#CCCCCC');

  return {
    'kategori': kategori?.baslik ?? '-',
    'oncelik': oncelik?.baslik ?? '-',
    'color': color,
  };
});

/// 📄 2. NotCard Widget'ı (Artık Stateless / ConsumerWidget)
class NotCard extends ConsumerWidget {
  final Not not;

  const NotCard({
    super.key,
    required this.not,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = AppConfig.dateFormat.format(not.kayitZamani);

    // ✅ Provider'ı izliyoruz. 'not' parametresini gönderiyoruz.
    final cardDataAsync = ref.watch(notCardDataProvider(not));

    return cardDataAsync.when(
      // ⏳ Yükleniyor
      loading: () => Card(
        color: Colors.grey.shade100,
        child: const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),

      // ❌ Hata
      error: (error, stack) => _buildErrorCard(error.toString()),

      // ✅ Veri Hazır
      data: (data) {
        return _buildNotCard(
          kategoriAdi: data['kategori'],
          oncelikAdi: data['oncelik'],
          color: data['color'],
          formattedDate: formattedDate,
        );
      },
    );
  }

  Widget _buildNotCard({
    required String kategoriAdi,
    required String oncelikAdi,
    required Color color,
    required String formattedDate,
  }) {
    return Card(
      color: color,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minHeight: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kategoriAdi,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  oncelikAdi,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              not.baslik,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              not.aciklama,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          '❌ Hata: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
