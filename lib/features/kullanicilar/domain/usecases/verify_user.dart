import '../repositories/kullanici_repository.dart';

class VerifyUser {
  final KullaniciRepository repository;

  VerifyUser(this.repository);

  // Parametre adı değişti: email -> securityCode
  Future<bool> call(String userName, String securityCode) async {
    return await repository.verifyUser(userName, securityCode);
  }
}
