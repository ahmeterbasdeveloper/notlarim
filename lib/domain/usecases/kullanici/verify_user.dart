import '../../repositories/kullanici_repository.dart';

class VerifyUser {
  final KullaniciRepository repository;

  VerifyUser(this.repository);

  Future<bool> call(String userName, String email) async {
    return await repository.verifyUser(userName, email);
  }
}
