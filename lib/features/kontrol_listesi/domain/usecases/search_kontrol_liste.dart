import '../entities/kontrol_liste.dart';
import '../repositories/kontrol_liste_repository.dart';

class SearchKontrolListe {
  final KontrolListeRepository repository;
  SearchKontrolListe(this.repository);

  Future<List<KontrolListe>> call(String query) async {
    return await repository.searchKontrolListesi(query);
  }
}
