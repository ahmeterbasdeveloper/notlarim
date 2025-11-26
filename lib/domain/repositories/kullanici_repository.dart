abstract class KullaniciRepository {
  /// Email ve Şifre ile giriş kontrolü yapar.
  /// Başarılı ise true, değilse false döner.
  Future<bool> login(String email, String password);
}
