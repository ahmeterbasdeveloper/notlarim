import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class GetNotById {
  final NotRepository repository;

  GetNotById(this.repository);

  Future<Not?> call(int id) async {
    return await repository.getNotById(id);
  }
}
