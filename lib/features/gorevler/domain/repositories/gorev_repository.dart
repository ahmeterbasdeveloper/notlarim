import '../entities/gorev.dart';
import '../../../../core/base/crud_repository.dart';

abstract class GorevRepository extends CrudRepository<Gorev> {
  // ✅ Arama metodu eklendi
  Future<List<Gorev>> searchGorevler(String query);
}
