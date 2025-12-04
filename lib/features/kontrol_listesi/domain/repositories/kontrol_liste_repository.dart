import '../entities/kontrol_liste.dart';
import '../../../../core/base/crud_repository.dart';

abstract class KontrolListeRepository extends CrudRepository<KontrolListe> {
  // ❌ Standard CRUD metodlarını (getAll, getById, create, update, delete) SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<List<KontrolListe>> getByDurum(int durumId);
}
