import '../../repositories/oncelik_repository.dart';

class DeleteOncelik {
  final OncelikRepository repository;

  DeleteOncelik(this.repository);

  Future<void> call(int id) async {
    await repository.deleteOncelik(id);
  }
}
