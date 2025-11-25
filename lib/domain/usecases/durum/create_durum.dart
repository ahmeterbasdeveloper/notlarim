// lib/features/notes/domain/usecases/create_durum.dart
import '../../entities/durum.dart';
import '../../repositories/durum_repository.dart';

class CreateDurum {
  final DurumRepository repository;

  CreateDurum(this.repository);

  Future<Durum> call(Durum durum) {
    return repository.createDurum(durum);
  }
}
