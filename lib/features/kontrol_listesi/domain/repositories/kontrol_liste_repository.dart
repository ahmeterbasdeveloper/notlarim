import '../entities/kontrol_liste.dart';
import '../../../../core/base/crud_repository.dart';

abstract class KontrolListeRepository extends CrudRepository<KontrolListe> {
  Future<List<KontrolListe>> getByDurum(int durumId);
  // ✅ EKLE:
  Future<List<KontrolListe>> searchKontrolListesi(String query);
}
