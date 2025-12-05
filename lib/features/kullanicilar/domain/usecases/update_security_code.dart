import '../repositories/kullanici_repository.dart';

class UpdateSecurityCode {
  final KullaniciRepository repository;

  UpdateSecurityCode(this.repository);

  Future<void> call(String userName, String newCode) {
    return repository.updateSecurityCode(userName, newCode);
  }
}
