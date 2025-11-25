// lib/features/notes/data/models/durumlar_model.dart

import '../../domain/entities/durum.dart';

/// 🗃️ SQLite tablosu adı
const String tableDurumlar = 'durumlar';

/// 🏷️ Veritabanı alanları
class DurumAlanlar {
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
class DurumModel extends Durum {
  const DurumModel({
    super.id,
    required super.baslik,
    required super.aciklama,
    required super.renkKodu,
    required super.kayitZamani,
    required super.sabitMi,
  });

  /// 🔁 Domain Entity'den Model'e dönüştürme
  factory DurumModel.fromEntity(Durum entity) => DurumModel(
        id: entity.id,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        renkKodu: entity.renkKodu,
        kayitZamani: entity.kayitZamani,
        sabitMi: entity.sabitMi,
      );

  /// 🔁 Model'den Domain Entity'ye dönüştürme
  Durum toEntity() => Durum(
        id: id,
        baslik: baslik,
        aciklama: aciklama,
        renkKodu: renkKodu,
        kayitZamani: kayitZamani,
        sabitMi: sabitMi,
      );

  /// 🧱 SQLite / JSON’dan Model’e dönüştürme
  factory DurumModel.fromJson(Map<String, Object?> json) => DurumModel(
        id: json[DurumAlanlar.id] as int?,
        baslik: json[DurumAlanlar.baslik] as String,
        aciklama: json[DurumAlanlar.aciklama] as String,
        renkKodu: json[DurumAlanlar.renkKodu] as String,
        kayitZamani: DateTime.parse(json[DurumAlanlar.kayitZamani] as String),
        sabitMi: json[DurumAlanlar.sabitMi] as int?,
      );

  /// 🗂️ Model’den SQLite / JSON’a dönüştürme
  Map<String, Object?> toJson() => {
        DurumAlanlar.id: id,
        DurumAlanlar.baslik: baslik,
        DurumAlanlar.aciklama: aciklama,
        DurumAlanlar.renkKodu: renkKodu,
        DurumAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        DurumAlanlar.sabitMi: sabitMi,
      };

  /// 🔄 Kopya oluşturmak için
  @override
  DurumModel copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    String? renkKodu,
    DateTime? kayitZamani,
    int? sabitMi,
  }) {
    return DurumModel(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      renkKodu: renkKodu ?? this.renkKodu,
      kayitZamani: kayitZamani ?? this.kayitZamani,
      sabitMi: sabitMi ?? this.sabitMi,
    );
  }
}