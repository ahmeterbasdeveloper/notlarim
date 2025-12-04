import '../repositories/kullanici_repository.dart';

class UpdatePassword {
  final KullaniciRepository repository;

  UpdatePassword(this.repository);

  Future<void> call(String userName, String newPassword) async {
    return await repository.updatePassword(userName, newPassword);
  }
}
