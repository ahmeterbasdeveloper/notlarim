import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/database/database_backup_restore.dart';
import '../../../../core/database/database_helper.dart';

// İlgili UseCase ve Provider'lar
import '../../../kullanicilar/presentation/providers/kullanici_di_providers.dart';
import '../../../notlar/presentation/providers/not_providers.dart';
// ... Diğer provider importları (kategori, durum vb.)

// ✅ State: İşlemin durumunu tutar (Loading, Error, Success)
class AnaMenuState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AnaMenuState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AnaMenuState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AnaMenuState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage, // Null gönderilirse null olsun (resetlemek için)
      successMessage: successMessage,
    );
  }
}

// ✅ Controller: İş Mantığı
class AnaMenuController extends StateNotifier<AnaMenuState> {
  final Ref _ref;

  AnaMenuController(this._ref) : super(AnaMenuState());

  // 1. Kullanıcı Doğrulama (Güvenlik Kodu veya Şifre Değişimi öncesi)
  Future<bool> verifyUserCredentials(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result =
          await _ref.read(loginUserProvider).call(username, password);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Doğrulama hatası: $e");
      return false;
    }
  }

  // 2. Güvenlik Kodu Doğrulama
  Future<bool> verifySecurityCode(String username, String code) async {
    // UI'ı bloklamamak için loading açmıyoruz veya isteğe bağlı açabiliriz
    try {
      return await _ref.read(verifySecurityCodeProvider).call(username, code);
    } catch (e) {
      state = state.copyWith(errorMessage: "Kod doğrulama hatası: $e");
      return false;
    }
  }

  // 3. Şifre Güncelleme
  Future<bool> updatePassword(String username, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(updatePasswordProvider).call(username, newPassword);
      state = state.copyWith(
          isLoading: false, successMessage: "Şifre başarıyla güncellendi.");
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Hata: $e");
      return false;
    }
  }

  // 4. Güvenlik Kodu Güncelleme
  Future<bool> updateSecurityCode(String username, String newCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(updateSecurityCodeProvider).call(username, newCode);
      state = state.copyWith(
          isLoading: false, successMessage: "Güvenlik kodu güncellendi.");
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Hata: $e");
      return false;
    }
  }

  // 5. Yedek Alma
  Future<bool> backupDatabase(String fileName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final file = await DatabaseBackupRestore.instance
          .backupDatabase(fileName: '$fileName.db');
      state = state.copyWith(
          isLoading: false,
          successMessage: file != null ? "Yedek başarıyla alındı." : null,
          errorMessage: file == null ? "Yedek alınamadı." : null);
      return file != null;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Yedekleme hatası: $e");
      return false;
    }
  }

  // 6. Geri Yükleme
  Future<bool> restoreDatabase(String fileName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success =
          await DatabaseBackupRestore.instance.restoreDatabase(fileName);
      if (success) {
        // Tüm listeleri yenile
        _refreshAllProviders();
        state = state.copyWith(
            isLoading: false, successMessage: "Veritabanı geri yüklendi.");
      } else {
        state = state.copyWith(
            isLoading: false, errorMessage: "Geri yükleme başarısız.");
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Hata: $e");
      return false;
    }
  }

  // 7. Fabrika Ayarlarına Dön
  Future<void> factoryReset() async {
    state = state.copyWith(isLoading: true);
    try {
      await DatabaseHelper.instance.factoryReset();
      _refreshAllProviders();
      state = state.copyWith(
          isLoading: false, successMessage: "Fabrika ayarlarına dönüldü.");
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Sıfırlama hatası: $e");
    }
  }

  // Yardımcı: Tüm providerları yenile
  void _refreshAllProviders() {
    _ref.invalidate(notNotifierProvider);
    // ... Diğer tüm listelerin provider'larını invalidate et
    // _ref.invalidate(kategoriNotifierProvider); vb.
  }

  // Hata/Başarı mesajını temizle (UI'da gösterdikten sonra çağırmak için)
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ✅ Provider Tanımı
final anaMenuControllerProvider =
    StateNotifierProvider<AnaMenuController, AnaMenuState>((ref) {
  return AnaMenuController(ref);
});
