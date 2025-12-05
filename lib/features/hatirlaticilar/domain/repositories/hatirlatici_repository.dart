import '../entities/hatirlatici.dart';
import '../../../../core/base/crud_repository.dart';

abstract class HatirlaticiRepository extends CrudRepository<Hatirlatici> {
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId);
  // ✅ Arama metodu eklendi
  Future<List<Hatirlatici>> searchHatirlaticilar(String query);
}
