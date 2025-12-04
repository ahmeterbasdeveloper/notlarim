// lib/domain/entities/not.dart

import '../../core/base/base_entity.dart';

/// 🧱 Domain Entity — BaseEntity'den türetildi
class Not extends BaseEntity {
  // ❌ 'final int? id;' satırını sildik çünkü BaseEntity içinde zaten var.

  final int kategoriId;
  final int oncelikId;
  final String baslik;
  final String aciklama;
  final DateTime kayitZamani;
  final int durumId;

  const Not({
    super.id, // ✅ id parametresini BaseEntity'ye gönderiyoruz
    required this.kategoriId,
    required this.oncelikId,
    required this.baslik,
    required this.aciklama,
    required this.kayitZamani,
    required this.durumId,
  });

  /// ✅ Generic Repository create/update işlemleri için gerekli
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id, // SQLite'daki kolon adı '_id' ise
      'kategoriId': kategoriId,
      'oncelikId': oncelikId,
      'baslik': baslik,
      'aciklama': aciklama,
      'kayitZamani': kayitZamani.toIso8601String(), // DateTime -> String
      'durumId': durumId,
    };
  }

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
      id: id ?? this.id, // this.id artık BaseEntity'den geliyor
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
