import '../../entities/gorev.dart';
import '../../repositories/gorev_repository.dart';

/// 🧩 ID’ye göre tek görev getirme UseCase'i
class GetGorevById {
  final GorevRepository repository;

  GetGorevById(this.repository);

  Future<Gorev> call(int id) {
    return repository.getGorevById(id);
  }
}
