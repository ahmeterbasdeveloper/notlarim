import '../../../../core/base/base_entity.dart';

class Kategori extends BaseEntity {
  final String baslik;
  final String aciklama;
  final String renkKodu;
  final DateTime kayitZamani;
  final bool sabitMi;

  const Kategori({
    super.id, // BaseEntity'den gelen id
    required this.baslik,
    required this.aciklama,
    required this.renkKodu,
    required this.kayitZamani,
    required this.sabitMi,
  });

  // ⚠️ Generic Repository'nin çalışması için bu metodun burada tanımlı olması gerekir.
  // Ancak Clean Architecture gereği içini boş bırakıp Model sınıfında doldurabilirsiniz
  // veya basitlik adına burada da doldurabilirsiniz. Aşağıda dolu halini veriyorum:
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id, // SQLite tablonuzdaki ID kolon adı '_id' ise
      'baslik': baslik,
      'aciklama': aciklama,
      'renkKodu': renkKodu,
      'kayitZamani': kayitZamani.toIso8601String(),
      'sabitMi': sabitMi ? 1 : 0, // SQLite boolean desteklemez, 0/1 kullanır
    };
  }

  @override
  Kategori copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    bool? sabitMi,
  }) {
    return Kategori(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }
}
