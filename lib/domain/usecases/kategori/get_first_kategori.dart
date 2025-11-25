import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

/// 🧩 Veritabanındaki ilk kategoriyi döndüren UseCase.
/// Clean Architecture yapısında Domain katmanında yer alır.
class GetFirstKategori {
  final KategoriRepository repository;

  GetFirstKategori(this.repository);

  /// İlk kategori kaydını getirir.
  Future<Kategori> call() async {
    return await repository.getIlkKategori();
  }
}
