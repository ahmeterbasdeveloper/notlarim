import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/repositories/hatirlatici_repository.dart';

class UpdateHatirlatici {
  final HatirlaticiRepository repository;

  UpdateHatirlatici(this.repository);

  Future<int> call(Hatirlatici hatirlatici) async {
    return repository.updateHatirlatici(hatirlatici);
  }
}
