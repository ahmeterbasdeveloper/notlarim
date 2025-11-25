import 'package:notlarim/domain/repositories/hatirlatici_repository.dart';

class DeleteHatirlatici {
  final HatirlaticiRepository repository;

  DeleteHatirlatici(this.repository);

  Future<int> call(int id) async {
    return repository.deleteHatirlatici(id);
  }
}
