import '../repositories/kullanici_repository.dart';

class LoginUser {
  final KullaniciRepository repository;

  LoginUser(this.repository);

  // Burası Future<void> değil, Future<bool> olmalı!
  Future<bool> call(String userName, String password) {
    return repository.login(userName, password);
  }
}
