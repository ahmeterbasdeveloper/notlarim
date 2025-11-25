import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

class CreateKategori {
  final KategoriRepository repository;

  CreateKategori(this.repository);

  Future<Kategori> call(Kategori kategori) {
    return repository.createKategori(kategori);
  }
}
