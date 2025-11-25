/// 🧱 Domain Entity — yalnızca iş mantığını temsil eder.
/// Veri tabanı, JSON veya UI detayları içermez.
class Gorev {
  final int? id;
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
    this.id,
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

  /// Yeni bir Gorev nesnesi oluşturmak veya mevcut olanı kopyalamak için
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

  /// Karşılaştırmalar ve testler için eşitlik operatörü
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gorev &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          grupId == other.grupId &&
          baslik == other.baslik &&
          aciklama == other.aciklama &&
          kategoriId == other.kategoriId &&
          oncelikId == other.oncelikId &&
          baslamaTarihiZamani == other.baslamaTarihiZamani &&
          bitisTarihiZamani == other.bitisTarihiZamani &&
          kayitZamani == other.kayitZamani &&
          durumId == other.durumId;

  @override
  int get hashCode => Object.hash(
        id,
        grupId,
        baslik,
        aciklama,
        kategoriId,
        oncelikId,
        baslamaTarihiZamani,
        bitisTarihiZamani,
        kayitZamani,
        durumId,
      );

  @override
  String toString() =>
      'Gorev(id: $id, grupId: $grupId, baslik: $baslik, aciklama: $aciklama, kategoriId: $kategoriId, oncelikId: $oncelikId, baslama: $baslamaTarihiZamani, bitis: $bitisTarihiZamani, kayit: $kayitZamani, durumId: $durumId)';
}
