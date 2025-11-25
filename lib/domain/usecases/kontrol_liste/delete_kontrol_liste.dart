import '../../repositories/kontrol_liste_repository.dart';

class DeleteKontrolListe {
  final KontrolListeRepository repository;

  DeleteKontrolListe(this.repository);

  Future<int> call(int id) async {
    return await repository.delete(id);
  }
}
