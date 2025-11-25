import '../entities/kontrol_liste.dart';

abstract class KontrolListeRepository {
  Future<KontrolListe> getById(int id);
  Future<List<KontrolListe>> getAll();
  Future<List<KontrolListe>> getByDurum(int durumId);
  Future<KontrolListe> create(KontrolListe kontrolListe);
  Future<int> update(KontrolListe kontrolListe);
  Future<int> delete(int id);
}
