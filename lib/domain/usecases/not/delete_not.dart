import '../../repositories/not_repository.dart';

class DeleteNot {
  final NotRepository repository;

  DeleteNot(this.repository);

  Future<int> call(int id) async {
    return await repository.deleteNot(id);
  }
}
