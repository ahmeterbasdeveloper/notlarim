import '../../entities/kontrol_liste.dart';
import '../../repositories/kontrol_liste_repository.dart';

class UpdateKontrolListe {
  final KontrolListeRepository repository;

  UpdateKontrolListe(this.repository);

  Future<int> call(KontrolListe kontrolListe) async {
    return await repository.update(kontrolListe);
  }
}
