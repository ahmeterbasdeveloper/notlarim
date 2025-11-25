/// 🧠 Domain katmanı - KontrolListe Entity
class KontrolListe {
  final int? id;
  final int kategoriId;
  final int oncelikId;
  final String baslik;
  final String aciklama;
  final DateTime kayitZamani;
  final int durumId;

  const KontrolListe({
    this.id,
    required this.kategoriId,
    required this.oncelikId,
    required this.baslik,
    required this.aciklama,
    required this.kayitZamani,
    required this.durumId,
  });

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
