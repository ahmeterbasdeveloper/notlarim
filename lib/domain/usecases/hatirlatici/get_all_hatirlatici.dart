import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/repositories/hatirlatici_repository.dart';

class GetAllHatirlatici {
  final HatirlaticiRepository repository;

  GetAllHatirlatici(this.repository);

  Future<List<Hatirlatici>> call() async {
    return repository.getAllHatirlatici();
  }
}
