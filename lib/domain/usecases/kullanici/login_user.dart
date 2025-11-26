import '../../repositories/kullanici_repository.dart';

class LoginUser {
  final KullaniciRepository repository;

  LoginUser(this.repository);

  Future<bool> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
