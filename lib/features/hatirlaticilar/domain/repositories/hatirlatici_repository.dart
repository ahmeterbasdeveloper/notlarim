import '../entities/hatirlatici.dart';
import '../../../../core/base/crud_repository.dart';

abstract class HatirlaticiRepository extends CrudRepository<Hatirlatici> {
  // ❌ create, update, delete, getAll metodlarını SİLİN.
  // BaseRepository bunları sağlıyor.

  // 👇 Sadece özel metodlar kalmalı:
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId);
}
