import '../../domain/entities/oncelik.dart';

/// 🗃️ SQLite tablosu adı
const String tableOncelik = 'oncelikler';

/// 🏷️ Veritabanı alanları
class OncelikAlanlar {
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
class OncelikModel extends Oncelik {
  const OncelikModel({
    super.id,
    required super.baslik,
    required super.aciklama,
    required super.renkKodu,
    required super.kayitZamani,
    required super.sabitMi,
  });

  /// 🔁 Domain Entity'den Model’e dönüştürme
  factory OncelikModel.fromEntity(Oncelik entity) => OncelikModel(
        id: entity.id,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        renkKodu: entity.renkKodu,
        kayitZamani: entity.kayitZamani,
        sabitMi: entity.sabitMi,
      );

  /// 🔁 Model’den Domain Entity’ye dönüştürme
  Oncelik toEntity() => Oncelik(
        id: id,
        baslik: baslik,
        aciklama: aciklama,
        renkKodu: renkKodu,
        kayitZamani: kayitZamani,
        sabitMi: sabitMi,
      );

  /// 🧱 SQLite / JSON’dan Model’e dönüştürme
  factory OncelikModel.fromJson(Map<String, Object?> json) => OncelikModel(
        id: json[OncelikAlanlar.id] as int?,
        baslik: json[OncelikAlanlar.baslik] as String,
        aciklama: json[OncelikAlanlar.aciklama] as String,
        renkKodu: json[OncelikAlanlar.renkKodu] as String,
        kayitZamani:
            DateTime.parse(json[OncelikAlanlar.kayitZamani] as String),
        sabitMi: (json[OncelikAlanlar.sabitMi] as int? ?? 0) == 1,
      );

  /// 🗂️ Model’den SQLite / JSON’a dönüştürme
  Map<String, Object?> toJson() => {
        OncelikAlanlar.id: id,
        OncelikAlanlar.baslik: baslik,
        OncelikAlanlar.aciklama: aciklama,
        OncelikAlanlar.renkKodu: renkKodu,
        OncelikAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        OncelikAlanlar.sabitMi: sabitMi ? 1 : 0,
      };

  /// 🔄 Kopya oluşturmak için
  @override
  OncelikModel copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    bool? sabitMi,
  }) {
    return OncelikModel(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }
}