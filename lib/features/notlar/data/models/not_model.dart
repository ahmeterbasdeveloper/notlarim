import '../../domain/entities/not.dart';

/// 🗃️ SQLite tablosu adı
const String tableNotlar = 'notlar';

/// 🏷️ Veritabanı alanları
class NotAlanlar {
  static final List<String> values = [
    id,
    kategoriId,
    oncelikId,
    baslik,
    aciklama,
    kayitZamani,
    durumId,
  ];

  static const String id = '_id';
  static const String kategoriId = 'kategoriId';
  static const String oncelikId = 'oncelikId';
  static const String baslik = 'baslik';
  static const String aciklama = 'aciklama';
  static const String kayitZamani = 'kayitZamani';
  static const String durumId = 'durumId';
}

/// 📦 Data Model — Entity’den miras alır.
/// Veritabanı veya JSON dönüşümlerini içerir.
class NotModel extends Not {
  const NotModel({
    super.id,
    required super.kategoriId,
    required super.oncelikId,
    required super.baslik,
    required super.aciklama,
    required super.kayitZamani,
    required super.durumId,
  });

  /// 🔁 Domain Entity'den Model’e dönüştürme
  factory NotModel.fromEntity(Not entity) => NotModel(
        id: entity.id,
        kategoriId: entity.kategoriId,
        oncelikId: entity.oncelikId,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        kayitZamani: entity.kayitZamani,
        durumId: entity.durumId,
      );

  /// 🔁 Model’den Domain Entity’ye dönüştürme
  Not toEntity() => Not(
        id: id,
        kategoriId: kategoriId,
        oncelikId: oncelikId,
        baslik: baslik,
        aciklama: aciklama,
        kayitZamani: kayitZamani,
        durumId: durumId,
      );

  /// 🧱 SQLite / JSON’dan Model’e dönüştürme
  factory NotModel.fromJson(Map<String, Object?> json) => NotModel(
        id: json[NotAlanlar.id] as int?,
        kategoriId: json[NotAlanlar.kategoriId] as int,
        oncelikId: json[NotAlanlar.oncelikId] as int,
        baslik: json[NotAlanlar.baslik] as String,
        aciklama: json[NotAlanlar.aciklama] as String,
        kayitZamani: DateTime.parse(json[NotAlanlar.kayitZamani] as String),
        durumId: json[NotAlanlar.durumId] as int,
      );

  /// 🗂️ Model’den SQLite / JSON’a dönüştürme
  Map<String, Object?> toJson() => {
        NotAlanlar.id: id,
        NotAlanlar.kategoriId: kategoriId,
        NotAlanlar.oncelikId: oncelikId,
        NotAlanlar.baslik: baslik,
        NotAlanlar.aciklama: aciklama,
        NotAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        NotAlanlar.durumId: durumId,
      };

  /// 🔄 Kopya oluşturmak için
  @override
  NotModel copyWith({
    int? id,
    int? kategoriId,
    int? oncelikId,
    String? baslik,
    String? aciklama,
    DateTime? kayitZamani,
    int? durumId,
  }) {
    return NotModel(
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
