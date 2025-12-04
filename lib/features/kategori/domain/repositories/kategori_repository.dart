// lib/domain/repositories/kategori_repository.dart

import '../entities/kategori.dart';
import '../../../../core/base/crud_repository.dart';

abstract class KategoriRepository extends CrudRepository<Kategori> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<Kategori> getIlkKategori();
}
