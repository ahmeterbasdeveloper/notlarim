abstract class KullaniciRepository {
  Future<bool> login(String userName, String password);

  // 👇 YENİ EKLENENLER
  Future<bool> verifyUser(String userName, String email); // Kullanıcıyı doğrula
  Future<void> updatePassword(
      String userName, String newPassword); // Şifreyi güncelle
}
