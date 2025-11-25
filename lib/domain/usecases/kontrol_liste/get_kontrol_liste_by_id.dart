import '../../entities/kontrol_liste.dart';
import '../../repositories/kontrol_liste_repository.dart';

class GetKontrolListeById {
  final KontrolListeRepository repository;

  GetKontrolListeById(this.repository);

  Future<KontrolListe> call(int id) async {
    return await repository.getById(id);
  }
}
