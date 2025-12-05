import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/core_providers.dart';

// Repository
import '../../domain/repositories/kullanici_repository.dart';
import '../../data/repositories/kullanici_repository_impl.dart';

// UseCases
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/verify_user.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/verify_security_code.dart';
import '../../domain/usecases/update_security_code.dart'; // ✅ Yeni UseCase importu

// --- REPOSITORY PROVIDER ---
// RepositoryImpl, DB servisine ihtiyaç duyar (ref.watch(dbServiceProvider))
final kullaniciRepositoryProvider = Provider<KullaniciRepository>((ref) {
  return KullaniciRepositoryImpl(ref.watch(dbServiceProvider));
});

// --- USECASE PROVIDERS ---

// 1. Giriş Yapma
final loginUserProvider = Provider((ref) {
  return LoginUser(ref.watch(kullaniciRepositoryProvider));
});

// 2. Kullanıcı Doğrulama (Şifremi unuttum için)
final verifyUserProvider = Provider((ref) {
  return VerifyUser(ref.watch(kullaniciRepositoryProvider));
});

// 3. Şifre Güncelleme
final updatePasswordProvider = Provider((ref) {
  return UpdatePassword(ref.watch(kullaniciRepositoryProvider));
});

// 4. Güvenlik Kodu Doğrulama
final verifySecurityCodeProvider = Provider((ref) {
  return VerifySecurityCode(ref.watch(kullaniciRepositoryProvider));
});

// ✅ 5. YENİ: Güvenlik Kodu Güncelleme
final updateSecurityCodeProvider = Provider((ref) {
  return UpdateSecurityCode(ref.watch(kullaniciRepositoryProvider));
});
