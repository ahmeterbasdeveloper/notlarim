import '../entities/gorev.dart';
import '../repositories/gorev_repository.dart';

class SearchGorev {
  final GorevRepository repository;
  SearchGorev(this.repository);

  Future<List<Gorev>> call(String query) async {
    return await repository.searchGorevler(query);
  }
}
