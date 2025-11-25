/// 🧱 Domain Entity — yalnızca iş mantığını temsil eder.
/// Veri tabanı, JSON veya UI detayları içermez.
class Not {
  final int? id;
  final int kategoriId;
  final int oncelikId;
  final String baslik;
  final String aciklama;
  final DateTime kayitZamani;
  final int durumId;

  const Not({
    this.id,
    required this.kategoriId,
    required this.oncelikId,
    required this.baslik,
    required this.aciklama,
    required this.kayitZamani,
    required this.durumId,
  });

  /// Yeni bir Not nesnesi oluşturmak veya mevcut olanı kopyalamak için
  Not copyWith({
    int? id,
    int? kategoriId,
    int? oncelikId,
    String? baslik,
    String? aciklama,
    DateTime? kayitZamani,
    int? durumId,
  }) {
    return Not(
      id: id ?? this.id,
      kategoriId: kategoriId ?? this.kategoriId,
      oncelikId: oncelikId ?? this.oncelikId,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      durumId: durumId ?? this.durumId,
    );
  }

  /// Karşılaştırmalar ve testler için eşitlik operatörü
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Not &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kategoriId == other.kategoriId &&
          oncelikId == other.oncelikId &&
          baslik == other.baslik &&
          aciklama == other.aciklama &&
          kayitZamani == other.kayitZamani &&
          durumId == other.durumId;

  @override
  int get hashCode => Object.hash(
        id,
        kategoriId,
        oncelikId,
        baslik,
        aciklama,
        kayitZamani,
        durumId,
      );

  @override
  String toString() =>
      'Not(id: $id, kategoriId: $kategoriId, oncelikId: $oncelikId, baslik: $baslik, aciklama: $aciklama, kayit: $kayitZamani, durumId: $durumId)';
}
