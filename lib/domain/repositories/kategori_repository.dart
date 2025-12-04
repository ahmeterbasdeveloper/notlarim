// lib/domain/repositories/kategori_repository.dart

import '../entities/kategori.dart';
import 'base_repository.dart';

abstract class KategoriRepository extends BaseRepository<Kategori> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<Kategori> getIlkKategori();
}
