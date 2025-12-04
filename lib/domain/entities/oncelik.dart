import '../../core/base/base_entity.dart';

/// 🧱 Domain Entity
class Oncelik extends BaseEntity {
  // ❌ 'final int? id;' satırını siliyoruz, BaseEntity'den geliyor.

  final String baslik;
  final String aciklama;
  final String renkKodu;
  final DateTime kayitZamani;
  final bool sabitMi;

  const Oncelik({
    super.id, // ✅ id BaseEntity'ye
    required this.baslik,
    required this.aciklama,
    required this.renkKodu,
    required this.kayitZamani,
    required this.sabitMi,
  });

  /// ✅ Generic Repository için gerekli toMap
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'renkKodu': renkKodu,
      'kayitZamani': kayitZamani.toIso8601String(),
      'sabitMi': sabitMi ? 1 : 0, // SQLite için bool -> int dönüşümü
    };
  }

  Oncelik copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    bool? sabitMi,
  }) {
    return Oncelik(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }
}
