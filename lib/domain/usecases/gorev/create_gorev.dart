import '../../entities/gorev.dart';
import '../../repositories/gorev_repository.dart';

/// 🧩 Yeni görev oluşturma UseCase'i
class CreateGorev {
  final GorevRepository repository;

  CreateGorev(this.repository);

  Future<Gorev> call(Gorev gorev) {
    return repository.createGorev(gorev);
  }
}
