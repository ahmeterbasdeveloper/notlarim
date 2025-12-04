import '../entities/kontrol_liste.dart';
import '../repositories/kontrol_liste_repository.dart';

class GetKontrolListeByDurum {
  final KontrolListeRepository repository;

  GetKontrolListeByDurum(this.repository);

  Future<List<KontrolListe>> call(int durumId) async {
    return await repository.getByDurum(durumId);
  }
}
