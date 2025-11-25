import '../../entities/oncelik.dart';
import '../../repositories/oncelik_repository.dart';

/// 🧩 Veritabanındaki ilk öncelik kaydını döndüren UseCase.
/// Clean Architecture yapısında Domain katmanında yer alır.
class GetFirstOncelik {
  final OncelikRepository repository;

  GetFirstOncelik(this.repository);

  /// İlk öncelik kaydını getirir.
  Future<Oncelik> call() async {
    return await repository.getIlkOncelik();
  }
}
