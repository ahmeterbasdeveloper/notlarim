import '../../entities/kontrol_liste.dart';
import '../../repositories/kontrol_liste_repository.dart';

class GetAllKontrolListe {
  final KontrolListeRepository repository;

  GetAllKontrolListe(this.repository);

  Future<List<KontrolListe>> call() async {
    return await repository.getAll();
  }
}
