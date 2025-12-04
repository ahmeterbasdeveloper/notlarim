// lib/domain/repositories/durum_repository.dart

import '../entities/durum.dart';
import 'base_repository.dart';

abstract class DurumRepository extends BaseRepository<Durum> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.
  // BaseRepository zaten bunları sağlıyor.

  // Eğer Durum'a özel bir sorgu (örn: Aktif durumları getir) yoksa,
  // burası boş kalabilir.
}
