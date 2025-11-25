// lib/features/notes/domain/usecases/update_durum.dart
import '../../entities/durum.dart';
import '../../repositories/durum_repository.dart';

class UpdateDurum {
  final DurumRepository repository;

  UpdateDurum(this.repository);

  Future<int> call(Durum durum) {
    return repository.updateDurum(durum);
  }
}
