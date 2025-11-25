import '../../entities/not.dart';
import '../../repositories/not_repository.dart';

class GetNotByOncelik {
  final NotRepository repository;

  GetNotByOncelik(this.repository);

  Future<List<Not>> call(int oncelikId) async {
    return await repository.getNotlarByOncelik(oncelikId);
  }
}
