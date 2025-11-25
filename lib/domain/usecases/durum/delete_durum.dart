// lib/features/notes/domain/usecases/delete_durum.dart
import '../../repositories/durum_repository.dart';

class DeleteDurum {
  final DurumRepository repository;

  DeleteDurum(this.repository);

  Future<int> call(int id) {
    return repository.deleteDurum(id);
  }
}
