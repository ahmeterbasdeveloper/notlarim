import '../../entities/kontrol_liste.dart';
import '../../repositories/kontrol_liste_repository.dart';

class CreateKontrolListe {
  final KontrolListeRepository repository;

  CreateKontrolListe(this.repository);

  Future<KontrolListe> call(KontrolListe kontrolListe) async {
    return await repository.create(kontrolListe);
  }
}
