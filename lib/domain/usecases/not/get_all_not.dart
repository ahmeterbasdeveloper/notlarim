import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class GetAllNot {
  final NotRepository repository;

  GetAllNot(this.repository);

  Future<List<Not>> call() async {
    return await repository.getAllNotlar();
  }
}
