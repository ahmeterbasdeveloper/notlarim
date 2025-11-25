import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class GetNotByKategori {
  final NotRepository repository;

  GetNotByKategori(this.repository);

  Future<List<Not>> call(int kategoriId) async {
    return await repository.getNotlarByKategori(kategoriId);
  }
}
