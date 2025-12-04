import '../entities/oncelik.dart';
import '../../../../core/base/crud_repository.dart';

abstract class OncelikRepository extends CrudRepository<Oncelik> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<Oncelik> getIlkOncelik();
}
