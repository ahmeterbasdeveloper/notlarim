import '../../core/base/base_entity.dart';

/// 🧠 Domain katmanı - KontrolListe Entity
class KontrolListe extends BaseEntity {
  // ❌ 'final int? id;' satırını siliyoruz, BaseEntity'den geliyor.

  final int kategoriId;
  final int oncelikId;
  final String baslik;
  final String aciklama;
  final DateTime kayitZamani;
  final int durumId;

  const KontrolListe({
    super.id, // ✅ id BaseEntity'ye
    required this.kategoriId,
    required this.oncelikId,
    required this.baslik,
    required this.aciklama,
    required this.kayitZamani,
    required this.durumId,
  });

  /// ✅ Generic Repository için gerekli
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'kategoriId': kategoriId,
      'oncelikId': oncelikId,
      'baslik': baslik,
      'aciklama': aciklama,
      'kayitZamani': kayitZamani.toIso8601String(),
      'durumId': durumId,
    };
  }

  KontrolListe copyWith({
    int? id,
    int? kategoriId,
    int? oncelikId,
    String? baslik,
    String? aciklama,
    DateTime? kayitZamani,
    int? durumId,
  }) {
    return KontrolListe(
      id: id ?? this.id,
      kategoriId: kategoriId ?? this.kategoriId,
      oncelikId: oncelikId ?? this.oncelikId,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      durumId: durumId ?? this.durumId,
    );
  }
}
