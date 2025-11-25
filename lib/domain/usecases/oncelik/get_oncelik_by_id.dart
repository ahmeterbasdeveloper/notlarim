import '../../entities/oncelik.dart';
import '../../repositories/oncelik_repository.dart';

class GetOncelikById {
  final OncelikRepository repository;

  GetOncelikById(this.repository);

  Future<Oncelik?> call(int id) async {
    return await repository.getOncelikById(id);
  }
}
