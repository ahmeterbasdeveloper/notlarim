// lib/domain/repositories/interfaces/writable_repository.dart
abstract class WritableRepository<T> {
  Future<int> create(T entity);
  Future<int> update(T entity);
  Future<int> delete(int id);
}
