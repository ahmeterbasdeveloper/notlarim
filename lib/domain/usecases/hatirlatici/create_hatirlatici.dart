import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/repositories/hatirlatici_repository.dart';

class CreateHatirlatici {
  final HatirlaticiRepository repository;

  CreateHatirlatici(this.repository);

  Future<Hatirlatici> call(Hatirlatici hatirlatici) async {
    return repository.createHatirlatici(hatirlatici);
  }
}
