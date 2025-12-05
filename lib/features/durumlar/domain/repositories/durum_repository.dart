// lib/domain/repositories/durum_repository.dart

import '../entities/durum.dart';
import '../../../../core/base/crud_repository.dart';

abstract class DurumRepository extends CrudRepository<Durum> {
  Future<List<Durum>> searchDurumlar(String query);
}
