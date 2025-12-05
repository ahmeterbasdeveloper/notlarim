import '../entities/kategori.dart';
import '../repositories/kategori_repository.dart';

class GetIlkKategori {
  final KategoriRepository repository;

  GetIlkKategori(this.repository);

  Future<Kategori> call() {
    return repository.getIlkKategori();
  }
}
