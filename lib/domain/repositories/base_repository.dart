import '../../core/base/base_entity.dart';

abstract class BaseRepository<T extends BaseEntity> {
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<int> create(T entity);
  Future<int> update(T entity);
  Future<int> delete(int id);
}
