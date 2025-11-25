import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

class GetAllKategori {
  final KategoriRepository repository;

  GetAllKategori(this.repository);

  Future<List<Kategori>> call() {
    return repository.getAllKategori();
  }
}
