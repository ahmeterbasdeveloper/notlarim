import '../entities/oncelik.dart';
import '../../../../core/base/crud_repository.dart';

abstract class OncelikRepository extends CrudRepository<Oncelik> {
  Future<Oncelik> getIlkOncelik();
  Future<List<Oncelik>> searchOncelikler(String query);
}
