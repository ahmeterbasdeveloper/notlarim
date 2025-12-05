// Eski hali:
// Future<List<T>> getAll();

// ✅ Yeni hali:
abstract class ReadOnlyRepository<T> {
  // limit: Sayfa başına kaç kayıt? (Örn: 20)
  // offset: Kaç kayıt atlansın? (Örn: Sayfa 2 için 20 kayıt atla)
  Future<List<T>> getAll({int? limit, int? offset});

  Future<T?> getById(int id);
}
