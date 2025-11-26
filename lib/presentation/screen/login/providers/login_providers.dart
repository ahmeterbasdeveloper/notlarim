import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/kullanici/login_user.dart';
import '../../../../core/di/injection_container.dart';

// 1. STATE
class LoginState {
  final bool isLoading;
  final bool? isSuccess;
  final String? errorMessage;

  LoginState({
    this.isLoading = false,
    this.isSuccess,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUser _loginUser;

  LoginNotifier(this._loginUser) : super(LoginState());

  Future<void> login(String email, String password) async {
    debugPrint('🚀 Login İşlemi Başlatıldı: Email: $email'); // LOG 1

    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: null);

    try {
      // UseCase çağırılır
      final result = await _loginUser(email, password);

      debugPrint('🔍 Login Sonucu: $result'); // LOG 2

      if (result) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: 'Kullanıcı bulunamadı veya şifre yanlış.');
      }
    } catch (e) {
      debugPrint('❌ Login Hatası: $e'); // LOG 3
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(sl<LoginUser>());
});
