import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/gorev.dart';

// ✅ Generic UseCase
import '../../../../core/usecases/crud_usecases.dart';
// ✅ DI Providers
import '../../../../core/di/gorev_di_providers.dart';

// 1. STATE
class GorevState {
  final List<Gorev> gorevler;
  final bool isLoading;
  final String? errorMessage;

  GorevState({
    this.gorevler = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GorevState copyWith({
    List<Gorev>? gorevler,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GorevState(
      gorevler: gorevler ?? this.gorevler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class GorevNotifier extends StateNotifier<GorevState> {
  final GetAllUseCase<Gorev> _getAllGorev;

  GorevNotifier(this._getAllGorev) : super(GorevState()) {
    loadGorevler();
  }

  Future<void> loadGorevler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllGorev.call();
      // Tarihe göre sıralama (İsteğe bağlı)
      result.sort(
          (a, b) => a.baslamaTarihiZamani.compareTo(b.baslamaTarihiZamani));

      state = state.copyWith(isLoading: false, gorevler: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final gorevNotifierProvider =
    StateNotifierProvider<GorevNotifier, GorevState>((ref) {
  // Generic Provider'ı çağırıyoruz
  final getAllGorev = ref.watch(getAllGorevProvider);
  return GorevNotifier(getAllGorev);
});
