abstract class KullaniciRepository {
  // 1. Giriş İşlemi
  Future<bool> login(String userName, String password);

  // 2. Şifremi Unuttum İşlemleri (GÜNCELLENDİ)
  // E-posta yerine Güvenlik Kodu alıyor
  Future<bool> verifyUser(String userName, String securityCode);

  Future<void> updatePassword(String userName, String newPassword);

  // 3. Güvenlik Kodu İşlemleri
  Future<bool> verifySecurityCode(String userName, String securityCode);

  // 4. Güvenlik Kodunu Güncelleme
  Future<void> updateSecurityCode(String userName, String newCode);
}
