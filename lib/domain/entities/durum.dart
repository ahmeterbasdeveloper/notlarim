// lib/domain/entities/durum.dart

import '../../core/base/base_entity.dart';

/// 🧱 Domain Entity — BaseEntity'den türetildi
class Durum extends BaseEntity {
  // ❌ 'final int? id;' satırını siliyoruz, BaseEntity'den geliyor.

  final String baslik;
  final String aciklama;
  final String renkKodu;
  final DateTime kayitZamani;
  final int? sabitMi; // SQLite bool desteklemediği için int (0/1) olabilir

  const Durum({
    super.id, // ✅ id BaseEntity'ye gönderiliyor
    required this.baslik,
    required this.aciklama,
    required this.renkKodu,
    required this.kayitZamani,
    required this.sabitMi,
  });

  /// ✅ Generic Repository için gerekli toMap metodu
  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'renkKodu': renkKodu,
      'kayitZamani': kayitZamani.toIso8601String(),
      'sabitMi': sabitMi,
    };
  }

  /// Kopyalama metodu (değişmedi)
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

  // ... (Equality operator ve hashCode aynen kalabilir)
}
