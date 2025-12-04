import '../entities/oncelik.dart';
import 'base_repository.dart';

abstract class OncelikRepository extends BaseRepository<Oncelik> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<Oncelik> getIlkOncelik();
}
