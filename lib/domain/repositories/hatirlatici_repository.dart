import '../entities/hatirlatici.dart';
import 'base_repository.dart';

abstract class HatirlaticiRepository extends BaseRepository<Hatirlatici> {
  // ❌ create, update, delete, getAll metodlarını SİLİN.
  // BaseRepository bunları sağlıyor.

  // 👇 Sadece özel metodlar kalmalı:
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId);
}
