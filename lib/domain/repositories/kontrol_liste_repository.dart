import '../entities/kontrol_liste.dart';
import 'base_repository.dart';

abstract class KontrolListeRepository extends BaseRepository<KontrolListe> {
  // ❌ Standard CRUD metodlarını (getAll, getById, create, update, delete) SİLİN.

  // 👇 Sadece özel metodlar kalmalı:
  Future<List<KontrolListe>> getByDurum(int durumId);
}
