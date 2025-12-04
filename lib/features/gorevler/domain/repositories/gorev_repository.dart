import '../entities/gorev.dart';
import '../../../../core/base/crud_repository.dart';

/// 🧩 Domain katmanındaki soyut repository arayüzü.
abstract class GorevRepository extends CrudRepository<Gorev> {
  // ❌ create, update, delete, getAll, getById metodlarını SİLİN.
  // BaseRepository zaten bunları sağlıyor.

  // Özel bir sorgu gerekirse buraya ekleyebilirsiniz.
}
