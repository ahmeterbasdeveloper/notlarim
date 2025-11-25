import '../../repositories/gorev_repository.dart';

/// 🧩 Görev silme UseCase'i
class DeleteGorev {
  final GorevRepository repository;

  DeleteGorev(this.repository);

  Future<int> call(int id) {
    return repository.deleteGorev(id);
  }
}
