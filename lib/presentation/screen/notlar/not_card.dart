import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_helper.dart';

// 🧠 Domain
import '../../../domain/entities/not.dart';
import '../../../domain/usecases/kategori/get_kategori_by_id.dart';
import '../../../domain/usecases/oncelik/get_oncelik_by_id.dart';

// DI Container
import '../../../../core/di/injection_container.dart'; // sl için gerekli

class NotCard extends StatefulWidget {
  final Not not;

  // Constructor'dan UseCase'leri kaldırdık
  const NotCard({
    super.key,
    required this.not,
  });

  @override
  State<NotCard> createState() => _NotCardState();
}

class _NotCardState extends State<NotCard> {
  late Future<Map<String, dynamic>> _cardData;

  // UseCase'leri burada tanımlıyoruz
  final GetKategoriById _getKategoriById = sl<GetKategoriById>();
  final GetOncelikById _getOncelikById = sl<GetOncelikById>();

  @override
  void initState() {
    super.initState();
    _cardData = _loadCardData();
  }

  @override
  void didUpdateWidget(covariant NotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.not.id != widget.not.id) {
      _cardData = _loadCardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = AppConfig.dateFormat.format(widget.not.kayitZamani);

    return FutureBuilder<Map<String, dynamic>>(
      future: _cardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final data = snapshot.data ?? {};
        final kategoriAdi = data['kategori'] ?? '-';
        final oncelikAdi = data['oncelik'] ?? '-';
        final color = data['color'] ?? Colors.grey.shade300;

        return _buildNotCard(
          kategoriAdi: kategoriAdi,
          oncelikAdi: oncelikAdi,
          color: color,
          formattedDate: formattedDate,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadCardData() async {
    try {
      // UseCase'leri local değişkenlerden kullanıyoruz
      final kategori = await _getKategoriById(widget.not.kategoriId);
      final oncelik = await _getOncelikById(widget.not.oncelikId);

      final color = ColorHelper.hexToColor(oncelik?.renkKodu ?? '#CCCCCC');

      return {
        'kategori': kategori.baslik ?? '-',
        'oncelik': oncelik?.baslik ?? '-',
        'color': color,
      };
    } catch (e) {
      debugPrint('⚠️ NotCard veri yükleme hatası: $e');
      return {
        'kategori': '-',
        'oncelik': '-',
        'color': Colors.grey.shade200,
      };
    }
  }

  Widget _buildNotCard({
    required String kategoriAdi,
    required String oncelikAdi,
    required Color color,
    required String formattedDate,
  }) {
    final not = widget.not;

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
