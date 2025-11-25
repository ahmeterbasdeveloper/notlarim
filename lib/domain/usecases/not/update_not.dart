import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class UpdateNot {
  final NotRepository repository;

  UpdateNot(this.repository);

  Future<int> call(Not not) async {
    return await repository.updateNot(not);
  }
}
