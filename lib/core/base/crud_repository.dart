// lib/domain/repositories/base_repository.dart (Veya CrudRepository)
// İkisini birleştiren ana arayüz
import 'package:notlarim/core/base/read_only_repository.dart';
import 'package:notlarim/core/base/writable_repository.dart';

abstract class CrudRepository<T>
    implements ReadOnlyRepository<T>, WritableRepository<T> {
  // Burası boş kalabilir, çünkü metotlar üst arayüzlerden gelir.
}
