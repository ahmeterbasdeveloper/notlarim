// lib/features/notes/domain/usecases/get_durum_by_id.dart
import '../../entities/durum.dart';
import '../../repositories/durum_repository.dart';

class GetDurumById {
  final DurumRepository repository;

  GetDurumById(this.repository);

  Future<Durum> call(int id) {
    return repository.getDurumById(id);
  }
}
