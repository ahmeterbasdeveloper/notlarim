import '../../domain/entities/hatirlatici.dart';

/// 🔹 Tablonun SQLite üzerindeki ismi
const String tableHatirlaticilar = 'hatirlaticilar';

/// 🔹 Kolon isimlerini merkezi bir yerden yönetmek için alanlar sınıfı
class HatirlaticiAlanlar {
  static final List<String> values = [
    id,
    baslik,
    aciklama,
    kategoriId,
    oncelikId,
    hatirlatmaTarihiZamani,
    kayitZamani,
    durumId
  ];

  static const String id = '_id';
  static const String baslik = 'baslik';
  static const String aciklama = 'aciklama';
  static const String kategoriId = 'kategoriId';
  static const String oncelikId = 'oncelikId';
  static const String hatirlatmaTarihiZamani = 'hatirlatmaTarihiZamani';
  static const String kayitZamani = 'kayitZamani';
  static const String durumId = 'durumId';
}

/// 🔹 DB / JSON Model
/// Bu sınıf hem SQLite hem de JSON formatı ile veri alışverişi yapar.
/// Domain katmanındaki `Hatirlatici` entity’sinden türetilmiştir.
class HatirlaticiModel extends Hatirlatici {
  const HatirlaticiModel({
    super.id,
    required super.baslik,
    required super.aciklama,
    required super.kategoriId,
    required super.oncelikId,
    required super.hatirlatmaTarihiZamani,
    required super.kayitZamani,
    required super.durumId,
  });

  /// 🔸 JSON veya DB satırından Model oluşturur
  factory HatirlaticiModel.fromJson(Map<String, dynamic> json) => HatirlaticiModel(
        id: json[HatirlaticiAlanlar.id] as int?,
        baslik: json[HatirlaticiAlanlar.baslik] as String? ?? '',
        aciklama: json[HatirlaticiAlanlar.aciklama] as String? ?? '',
        kategoriId: json[HatirlaticiAlanlar.kategoriId] as int? ?? 0,
        oncelikId: json[HatirlaticiAlanlar.oncelikId] as int? ?? 0,
        hatirlatmaTarihiZamani: DateTime.tryParse(
              json[HatirlaticiAlanlar.hatirlatmaTarihiZamani] as String? ?? '',
            ) ??
            DateTime.now(),
        kayitZamani: DateTime.tryParse(
              json[HatirlaticiAlanlar.kayitZamani] as String? ?? '',
            ) ??
            DateTime.now(),
        durumId: json[HatirlaticiAlanlar.durumId] as int? ?? 1,
      );

  /// 🔸 Model’i JSON (veya DB map) haline çevirir
  Map<String, Object?> toJson() => {
        HatirlaticiAlanlar.id: id,
        HatirlaticiAlanlar.baslik: baslik,
        HatirlaticiAlanlar.aciklama: aciklama,
        HatirlaticiAlanlar.kategoriId: kategoriId,
        HatirlaticiAlanlar.oncelikId: oncelikId,
        HatirlaticiAlanlar.hatirlatmaTarihiZamani:
            hatirlatmaTarihiZamani.toIso8601String(),
        HatirlaticiAlanlar.kayitZamani: kayitZamani.toIso8601String(),
        HatirlaticiAlanlar.durumId: durumId,
      };

  /// 🔸 Entity → Model dönüşümü
  factory HatirlaticiModel.fromEntity(Hatirlatici entity) => HatirlaticiModel(
        id: entity.id,
        baslik: entity.baslik,
        aciklama: entity.aciklama,
        kategoriId: entity.kategoriId,
        oncelikId: entity.oncelikId,
        hatirlatmaTarihiZamani: entity.hatirlatmaTarihiZamani,
        kayitZamani: entity.kayitZamani,
        durumId: entity.durumId,
      );

  /// 🔸 Model → Entity dönüşümü
  Hatirlatici toEntity() => Hatirlatici(
        id: id,
        baslik: baslik,
        aciklama: aciklama,
        kategoriId: kategoriId,
        oncelikId: oncelikId,
        hatirlatmaTarihiZamani: hatirlatmaTarihiZamani,
        kayitZamani: kayitZamani,
        durumId: durumId,
      );
}
