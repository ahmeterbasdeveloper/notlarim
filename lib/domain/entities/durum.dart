// lib/features/notes/domain/entities/durumlar.dart
/// 🧱 Domain Entity — yalnızca iş mantığını temsil eder.
/// Veri tabanı, JSON veya UI detayları içermez.
class Durum {
  final int? id;
  final String baslik;
  final String aciklama;
  final String renkKodu;
  final DateTime kayitZamani;
  final int? sabitMi;

  const Durum({
    this.id,
    required this.baslik,
    required this.aciklama,
    required this.renkKodu,
    required this.kayitZamani,
    required this.sabitMi,
  });

  /// Yeni bir Durum nesnesi oluşturmak veya mevcut olanı kopyalamak için
  Durum copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    int? sabitMi,
  }) {
    return Durum(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }

  /// Karşılaştırmalar ve testler için eşitlik operatörü
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Durum &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          baslik == other.baslik &&
          aciklama == other.aciklama &&
          renkKodu == other.renkKodu &&
          kayitZamani == other.kayitZamani &&
          sabitMi == other.sabitMi;

  @override
  int get hashCode =>
      Object.hash(id, baslik, aciklama, renkKodu, kayitZamani, sabitMi);

  @override
  String toString() =>
      'Durum(id: $id, baslik: $baslik, aciklama: $aciklama, renkKodu: $renkKodu, kayitZamani: $kayitZamani, sabitMi: $sabitMi)';
}