import '../../domain/entities/kontrol_liste.dart';

const String tableKontrolListe = 'kontrolliste';

class KontrolListeAlanlar {
  static final List<String> values = [
    id, kategoriId, oncelikId, baslik, aciklama, kayitZamani, durumId
  ];

  static const String id = '_id';
  static const String kategoriId = 'kategoriId';
  static const String oncelikId = 'oncelikId';
  static const String baslik = 'baslik';
  static const String aciklama = 'aciklama';
  static const String kayitZamani = 'kayitZamani';
  static const String durumId = 'durumId';
}

class KontrolListeModel extends KontrolListe {
  const KontrolListeModel({
    super.id,
    required super.kategoriId,
    required super.oncelikId,
    required super.baslik,
    required super.aciklama,
    required super.kayitZamani,
    required super.durumId,
  });

  /// Entity → Model dönüşümü (DB veya API’ye hazır)
  factory KontrolListeModel.fromJson(Map<String, Object?> json) {
    return KontrolListeModel(
      id: json[KontrolListeAlanlar.id] as int?,
      kategoriId: json[KontrolListeAlanlar.kategoriId] as int,
      oncelikId: json[KontrolListeAlanlar.oncelikId] as int,
      baslik: json[KontrolListeAlanlar.baslik] as String,
      aciklama: json[KontrolListeAlanlar.aciklama] as String,
      kayitZamani: DateTime.parse(json[KontrolListeAlanlar.kayitZamani] as String),
      durumId: json[KontrolListeAlanlar.durumId] as int,
    );
  }

  Map<String, Object?> toJson() {
    return {
      KontrolListeAlanlar.id: id,
      KontrolListeAlanlar.kategoriId: kategoriId,
      KontrolListeAlanlar.oncelikId: oncelikId,
      KontrolListeAlanlar.baslik: baslik,
      KontrolListeAlanlar.aciklama: aciklama,
      KontrolListeAlanlar.kayitZamani: kayitZamani.toIso8601String(),
      KontrolListeAlanlar.durumId: durumId,
    };
  }

  /// Model → Entity dönüşümü
  KontrolListe toEntity() {
    return KontrolListe(
      id: id,
      kategoriId: kategoriId,
      oncelikId: oncelikId,
      baslik: baslik,
      aciklama: aciklama,
      kayitZamani: kayitZamani,
      durumId: durumId,
    );
  }

  /// Entity → Model dönüşümü
  factory KontrolListeModel.fromEntity(KontrolListe entity) {
    return KontrolListeModel(
      id: entity.id,
      kategoriId: entity.kategoriId,
      oncelikId: entity.oncelikId,
      baslik: entity.baslik,
      aciklama: entity.aciklama,
      kayitZamani: entity.kayitZamani,
      durumId: entity.durumId,
    );
  }

  /// ✅ copyWith metodu - CRUD işlemleri için gerekli
  @override
  KontrolListeModel copyWith({
    int? id,
    int? kategoriId,
    int? oncelikId,
    String? baslik,
    String? aciklama,
    DateTime? kayitZamani,
    int? durumId,
  }) {
    return KontrolListeModel(
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
