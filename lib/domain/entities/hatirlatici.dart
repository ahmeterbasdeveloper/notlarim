import '../../core/base/base_entity.dart';

/// Domain Katmanı - Entity
class Hatirlatici extends BaseEntity {
  // ❌ 'final int? id;' satırını siliyoruz, BaseEntity'den geliyor.

  final String baslik;
  final String aciklama;
  final int kategoriId;
  final int oncelikId;
  final DateTime hatirlatmaTarihiZamani;
  final DateTime kayitZamani;
  final int durumId;

  const Hatirlatici({
    super.id, // ✅ id BaseEntity'ye
    required this.baslik,
    required this.aciklama,
    required this.kategoriId,
    required this.oncelikId,
    required this.hatirlatmaTarihiZamani,
    required this.kayitZamani,
    required this.durumId,
  });

  /// ✅ Generic Repository için gerekli toMap
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'kategoriId': kategoriId,
      'oncelikId': oncelikId,
      'hatirlatmaTarihiZamani': hatirlatmaTarihiZamani.toIso8601String(),
      'kayitZamani': kayitZamani.toIso8601String(),
      'durumId': durumId,
    };
  }

  Hatirlatici copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    int? kategoriId,
    int? oncelikId,
    DateTime? hatirlatmaTarihiZamani,
    DateTime? kayitZamani,
    int? durumId,
  }) =>
      Hatirlatici(
        id: id ?? this.id,
        baslik: baslik ?? this.baslik,
        aciklama: aciklama ?? this.aciklama,
        kategoriId: kategoriId ?? this.kategoriId,
        oncelikId: oncelikId ?? this.oncelikId,
        hatirlatmaTarihiZamani:
            hatirlatmaTarihiZamani ?? this.hatirlatmaTarihiZamani,
        kayitZamani: kayitZamani ?? this.kayitZamani,
        durumId: durumId ?? this.durumId,
      );
}
