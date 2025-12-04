import '../entities/not.dart';
import '../repositories/not_repository.dart';

class SearchNot {
  final NotRepository repository;

  SearchNot(this.repository);

  Future<List<Not>> call(String query) async {
    return await repository.searchNotlar(query);
  }
}
