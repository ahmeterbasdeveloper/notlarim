import '../../entities/oncelik.dart';
import '../../repositories/oncelik_repository.dart';

class UpdateOncelik {
  final OncelikRepository repository;

  UpdateOncelik(this.repository);

  Future<void> call(Oncelik oncelik) async {
    await repository.updateOncelik(oncelik);
  }
}
