import '../entities/hatirlatici.dart';
import '../repositories/hatirlatici_repository.dart';

class SearchHatirlatici {
  final HatirlaticiRepository repository;
  SearchHatirlatici(this.repository);

  Future<List<Hatirlatici>> call(String query) async {
    return await repository.searchHatirlaticilar(query);
  }
}
