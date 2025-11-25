import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class CreateNot {
  final NotRepository repository;

  CreateNot(this.repository);

  Future<Not> call(Not not) async {
    return await repository.createNot(not);
  }
}
