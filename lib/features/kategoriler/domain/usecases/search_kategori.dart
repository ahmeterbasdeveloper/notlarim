import '../entities/kategori.dart';
import '../repositories/kategori_repository.dart';

class SearchKategori {
  final KategoriRepository repository;

  SearchKategori(this.repository);

  Future<List<Kategori>> call(String query) async {
    return await repository.searchKategoriler(query);
  }
}
