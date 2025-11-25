import '../../repositories/kategori_repository.dart';

class DeleteKategori {
  final KategoriRepository repository;

  DeleteKategori(this.repository);

  Future<int> call(int id) {
    return repository.deleteKategori(id);
  }
}
