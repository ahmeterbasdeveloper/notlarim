import '../../entities/gorev.dart';
import '../../repositories/gorev_repository.dart';

/// 🧩 Görev güncelleme UseCase'i
class UpdateGorev {
  final GorevRepository repository;

  UpdateGorev(this.repository);

  Future<int> call(Gorev gorev) {
    return repository.updateGorev(gorev);
  }
}
