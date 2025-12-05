import '../repositories/kullanici_repository.dart';

class VerifySecurityCode {
  final KullaniciRepository repository;

  VerifySecurityCode(this.repository);

  Future<bool> call(String userName, String code) async {
    return await repository.verifySecurityCode(userName, code);
  }
}
