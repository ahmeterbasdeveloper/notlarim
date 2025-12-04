import '../../core/base/base_entity.dart';

/// 🧱 Domain Entity
class Gorev extends BaseEntity {
  // ❌ 'final int? id;' satırını siliyoruz, BaseEntity'den geliyor.

  final int grupId;
  final String baslik;
  final String aciklama;
  final int kategoriId;
  final int oncelikId;
  final DateTime baslamaTarihiZamani;
  final DateTime bitisTarihiZamani;
  final DateTime kayitZamani;
  final int durumId;

  const Gorev({
    super.id, // ✅ id BaseEntity'ye
    required this.grupId,
    required this.baslik,
    required this.aciklama,
    required this.kategoriId,
    required this.oncelikId,
    required this.baslamaTarihiZamani,
    required this.bitisTarihiZamani,
    required this.kayitZamani,
    required this.durumId,
  });

  /// ✅ Generic Repository için gerekli
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'grupId': grupId,
      'baslik': baslik,
      'aciklama': aciklama,
      'kategoriId': kategoriId,
      'oncelikId': oncelikId,
      'baslamaTarihiZamani': baslamaTarihiZamani.toIso8601String(),
      'bitisTarihiZamani': bitisTarihiZamani.toIso8601String(),
      'kayitZamani': kayitZamani.toIso8601String(),
      'durumId': durumId,
    };
  }

  // CopyWith (Aynen Kalabilir, sadece id güncellendi)
  Gorev copyWith({
    int? id,
    int? grupId,
    String? baslik,
    String? aciklama,
    int? kategoriId,
    int? oncelikId,
    DateTime? baslamaTarihiZamani,
    DateTime? bitisTarihiZamani,
    DateTime? kayitZamani,
    int? durumId,
  }) {
    return Gorev(
      id: id ?? this.id,
      grupId: grupId ?? this.grupId,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      kategoriId: kategoriId ?? this.kategoriId,
      oncelikId: oncelikId ?? this.oncelikId,
      baslamaTarihiZamani: baslamaTarihiZamani ?? this.baslamaTarihiZamani,
      bitisTarihiZamani: bitisTarihiZamani ?? this.bitisTarihiZamani,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      durumId: durumId ?? this.durumId,
    );
  }

  // hashCode ve operator == metodları aynen kalabilir
}
