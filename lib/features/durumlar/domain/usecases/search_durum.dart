import '../entities/durum.dart';
import '../repositories/durum_repository.dart';

class SearchDurum {
  final DurumRepository repository;
  SearchDurum(this.repository);

  Future<List<Durum>> call(String query) async {
    return await repository.searchDurumlar(query);
  }
}
