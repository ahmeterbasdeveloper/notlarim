import '../../domain/entities/kategori.dart';

/// 🗃️ SQLite tablosu adı
const String tableKategoriler = 'kategoriler';

/// 🏷️ Veritabanı alanları
class KategoriAlanlar {
  static final List<String> values = [
    id, baslik, aciklama, renkKodu, kayitZamani, sabitMi
  ];

  static const String id = '_id';
  static const String baslik = 'baslik';
  static const String aciklama = 'aciklama';
  static const String renkKodu = 'renkKodu';
  static const String kayitZamani = 'kayitZamani';
  static const String sabitMi = 'sabitMi';
}

/// 📦 Data Model — Entity’den miras alır.
/// Veritabanı veya JSON dönüşümlerini içerir.
class KategoriModel extends Kategori {
  const KategoriModel({
    super.id,
    required super.baslik,
    required super.aciklama,
    required super.renkKodu,
    required super.kayitZamani,
    required super.sabitMi,
  });

  /// 🔁 Domain Entity'den Model’e dönüştürme
  factory KategoriModel.fromEntity(Kategori entity) => KategoriModel(
        id: entity.id,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        renkKodu: entity.renkKodu,
        kayitZamani: entity.kayitZamani,
        sabitMi: entity.sabitMi,
      );

  /// 🔁 Model’den Domain Entity’ye dönüştürme
  Kategori toEntity() => Kategori(
        id: id,
        baslik: baslik,
        aciklama: aciklama,
        renkKodu: renkKodu,
        kayitZamani: kayitZamani,
        sabitMi: sabitMi,
      );

  /// 🧱 SQLite / JSON’dan Model’e dönüştürme
  factory KategoriModel.fromJson(Map<String, Object?> json) => KategoriModel(
        id: json[KategoriAlanlar.id] as int?,
        baslik: json[KategoriAlanlar.baslik] as String,
        aciklama: json[KategoriAlanlar.aciklama] as String,
        renkKodu: json[KategoriAlanlar.renkKodu] as String,
        kayitZamani:
            DateTime.parse(json[KategoriAlanlar.kayitZamani] as String),
        sabitMi: (json[KategoriAlanlar.sabitMi] as int? ?? 0) == 1,
      );

  /// 🗂️ Model’den SQLite / JSON’a dönüştürme
  Map<String, Object?> toJson() => {
        KategoriAlanlar.id: id,
        KategoriAlanlar.baslik: baslik,
        KategoriAlanlar.aciklama: aciklama,
        KategoriAlanlar.renkKodu: renkKodu,
        KategoriAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        KategoriAlanlar.sabitMi: sabitMi ? 1 : 0,
      };

  /// 🔄 Kopya oluşturmak için
  @override
  KategoriModel copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    bool? sabitMi,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }
}
