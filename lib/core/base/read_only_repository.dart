// lib/domain/repositories/interfaces/read_only_repository.dart
abstract class ReadOnlyRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(int id);
}
