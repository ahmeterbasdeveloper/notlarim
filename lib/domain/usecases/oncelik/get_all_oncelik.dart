import '../../entities/oncelik.dart';
import '../../repositories/oncelik_repository.dart';

class GetAllOncelik {
  final OncelikRepository repository;

  GetAllOncelik(this.repository);

  Future<List<Oncelik>> call() async {
    return await repository.getAllOncelik();
  }
}
