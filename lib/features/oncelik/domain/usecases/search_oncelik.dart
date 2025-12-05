import '../entities/oncelik.dart';
import '../repositories/oncelik_repository.dart';

class SearchOncelik {
  final OncelikRepository repository;

  SearchOncelik(this.repository);

  Future<List<Oncelik>> call(String query) async {
    return await repository.searchOncelikler(query);
  }
}
