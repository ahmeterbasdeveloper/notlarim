import '../../entities/oncelik.dart';
import '../../repositories/oncelik_repository.dart';

class CreateOncelik {
  final OncelikRepository repository;

  CreateOncelik(this.repository);

  Future<Oncelik> call(Oncelik oncelik) async {
    return await repository.createOncelik(oncelik);
  }
}
