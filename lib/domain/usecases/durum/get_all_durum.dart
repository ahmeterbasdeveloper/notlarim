// lib/features/notes/domain/usecases/get_all_durum.dart
import '../../entities/durum.dart';
import '../../repositories/durum_repository.dart';

class GetAllDurum {
  final DurumRepository repository;

  GetAllDurum(this.repository);

  Future<List<Durum>> call() {
    return repository.getAllDurum();
  }
}
