/// Domain Katmanı - Entity
class Hatirlatici {
  final int? id;
  final String baslik;
  final String aciklama;
  final int kategoriId;
  final int oncelikId;
  final DateTime hatirlatmaTarihiZamani;
  final DateTime kayitZamani;
  final int durumId;

  const Hatirlatici({
    this.id,
    required this.baslik,
    required this.aciklama,
    required this.kategoriId,
    required this.oncelikId,
    required this.hatirlatmaTarihiZamani,
    required this.kayitZamani,
    required this.durumId,
  });

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
