import '../../entities/gorev.dart';
import '../../repositories/gorev_repository.dart';

/// 🧩 Tüm görevleri listeleme UseCase'i
class GetAllGorev {
  final GorevRepository repository;

  GetAllGorev(this.repository);

  Future<List<Gorev>> call() {
    return repository.getAllGorev();
  }
}
