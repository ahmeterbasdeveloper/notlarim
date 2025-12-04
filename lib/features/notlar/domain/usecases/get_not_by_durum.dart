import '../entities/not.dart';
import '../repositories/not_repository.dart';

class GetNotByDurum {
  final NotRepository repository;

  GetNotByDurum(this.repository);

  Future<List<Not>> call(int durumId) async {
    return await repository.getNotlarByDurum(durumId);
  }
}
