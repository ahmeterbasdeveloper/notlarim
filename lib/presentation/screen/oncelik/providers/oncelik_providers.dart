import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/oncelik.dart';

// UseCases
import '../../../../domain/usecases/oncelik/get_all_oncelik.dart';

// DI
import '../../../../core/di/injection_container.dart';

// 1. STATE
class OncelikState {
  final List<Oncelik> oncelikler;
  final bool isLoading;
  final String? errorMessage;

  OncelikState({
    this.oncelikler = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OncelikState copyWith({
    List<Oncelik>? oncelikler,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OncelikState(
      oncelikler: oncelikler ?? this.oncelikler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class OncelikNotifier extends StateNotifier<OncelikState> {
  final GetAllOncelik _getAllOncelik;

  OncelikNotifier(this._getAllOncelik) : super(OncelikState()) {
    loadOncelikler();
  }

  Future<void> loadOncelikler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllOncelik();
      state = state.copyWith(isLoading: false, oncelikler: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final oncelikNotifierProvider =
    StateNotifierProvider<OncelikNotifier, OncelikState>((ref) {
  return OncelikNotifier(sl<GetAllOncelik>());
});
