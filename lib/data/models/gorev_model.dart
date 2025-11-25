import '../../domain/entities/gorev.dart';

/// 🗃️ SQLite tablosu adı
const String tableGorevler = 'gorevler';

/// 🏷️ Veritabanı alanları
class GorevAlanlar {
  static final List<String> values = [
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
  ];

  static const String id = '_id';
  static const String grupId = 'grupId';
  static const String baslik = 'baslik';
  static const String aciklama = 'aciklama';
  static const String kategoriId = 'kategoriId';
  static const String oncelikId = 'oncelikId';
  static const String baslamaTarihiZamani = 'baslamaTarihiZamani';
  static const String bitisTarihiZamani = 'bitisTarihiZamani';
  static const String kayitZamani = 'kayitZamani';
  static const String durumId = 'durumId';
}

/// 📦 Data Model — Entity’den miras alır.
/// Veritabanı veya JSON dönüşümlerini içerir.
class GorevModel extends Gorev {
  const GorevModel({
    super.id,
    required super.grupId,
    required super.baslik,
    required super.aciklama,
    required super.kategoriId,
    required super.oncelikId,
    required super.baslamaTarihiZamani,
    required super.bitisTarihiZamani,
    required super.kayitZamani,
    required super.durumId,
  });

  /// 🔁 Domain Entity'den Model’e dönüştürme
  factory GorevModel.fromEntity(Gorev entity) => GorevModel(
        id: entity.id,
        grupId: entity.grupId,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        kategoriId: entity.kategoriId,
        oncelikId: entity.oncelikId,
        baslamaTarihiZamani: entity.baslamaTarihiZamani,
        bitisTarihiZamani: entity.bitisTarihiZamani,
        kayitZamani: entity.kayitZamani,
        durumId: entity.durumId,
      );

  /// 🔁 Model’den Domain Entity’ye dönüştürme
  Gorev toEntity() => Gorev(
        id: id,
        grupId: grupId,
        baslik: baslik,
        aciklama: aciklama,
        kategoriId: kategoriId,
        oncelikId: oncelikId,
        baslamaTarihiZamani: baslamaTarihiZamani,
        bitisTarihiZamani: bitisTarihiZamani,
        kayitZamani: kayitZamani,
        durumId: durumId,
      );

  /// 🧱 SQLite / JSON’dan Model’e dönüştürme
  factory GorevModel.fromJson(Map<String, Object?> json) => GorevModel(
        id: json[GorevAlanlar.id] as int?,
        grupId: json[GorevAlanlar.grupId] as int,
        baslik: json[GorevAlanlar.baslik] as String,
        aciklama: json[GorevAlanlar.aciklama] as String,
        kategoriId: json[GorevAlanlar.kategoriId] as int,
        oncelikId: json[GorevAlanlar.oncelikId] as int,
        baslamaTarihiZamani:
            DateTime.parse(json[GorevAlanlar.baslamaTarihiZamani] as String),
        bitisTarihiZamani:
            DateTime.parse(json[GorevAlanlar.bitisTarihiZamani] as String),
        kayitZamani: DateTime.parse(json[GorevAlanlar.kayitZamani] as String),
        durumId: json[GorevAlanlar.durumId] as int,
      );

  /// 🗂️ Model’den SQLite / JSON’a dönüştürme
  Map<String, Object?> toJson() => {
        GorevAlanlar.id: id,
        GorevAlanlar.grupId: grupId,
        GorevAlanlar.baslik: baslik,
        GorevAlanlar.aciklama: aciklama,
        GorevAlanlar.kategoriId: kategoriId,
        GorevAlanlar.oncelikId: oncelikId,
        GorevAlanlar.baslamaTarihiZamani: baslamaTarihiZamani.toIso8601String(),
        GorevAlanlar.bitisTarihiZamani: bitisTarihiZamani.toIso8601String(),
        GorevAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        GorevAlanlar.durumId: durumId,
      };

  /// 🔄 Kopya oluşturmak için
  @override
  GorevModel copyWith({
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
    return GorevModel(
      id: id ?? this.id,
      grupId: grupId ?? this.grupId,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      kategoriId: kategoriId ?? this.kategoriId,
      oncelikId: oncelikId ?? this.oncelikId,
      baslamaTarihiZamani:
          baslamaTarihiZamani ?? this.baslamaTarihiZamani,
      bitisTarihiZamani: bitisTarihiZamani ?? this.bitisTarihiZamani,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      durumId: durumId ?? this.durumId,
    );
  }
}
