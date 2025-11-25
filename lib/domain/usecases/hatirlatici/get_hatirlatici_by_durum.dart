import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/repositories/hatirlatici_repository.dart';

class GetHatirlaticiByDurum {
  final HatirlaticiRepository repository;

  GetHatirlaticiByDurum(this.repository);

  Future<List<Hatirlatici>> call(int durumId) async {
    return repository.getHatirlaticiByDurum(durumId);
  }
}
