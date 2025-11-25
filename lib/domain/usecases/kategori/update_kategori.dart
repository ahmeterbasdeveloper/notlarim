import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

class UpdateKategori {
  final KategoriRepository repository;

  UpdateKategori(this.repository);

  Future<int> call(Kategori kategori) {
    return repository.updateKategori(kategori);
  }
}
