import '../../entities/kategori.dart';
import '../../repositories/kategori_repository.dart';

/// 🧩 Veritabanındaki ilk kategoriyi döndüren UseCase.
class GetFirstKategori {
  final KategoriRepository repository;

  GetFirstKategori(this.repository);

  Future<Kategori> call() async {
    // ✅ Bu metod Generic değil, özel tanımlandığı için ismi değişmedi.
    return await repository.getIlkKategori();
  }
}
