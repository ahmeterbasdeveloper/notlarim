import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

class GetKategoriById {
  final KategoriRepository repository;

  GetKategoriById(this.repository);

  Future<Kategori> call(int id) {
    return repository.getKategoriById(id);
  }
}
