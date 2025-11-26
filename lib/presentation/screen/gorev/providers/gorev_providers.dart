import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/gorev.dart';

// UseCase'ler
import '../../../../domain/usecases/gorev/get_all_gorev.dart';

// DI
import '../../../../core/di/injection_container.dart';

// 1. STATE: UI'ın ihtiyaç duyduğu veriler
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

// 2. NOTIFIER: İş Mantığı
class GorevNotifier extends StateNotifier<GorevState> {
  final GetAllGorev _getAllGorev;

  GorevNotifier(this._getAllGorev) : super(GorevState()) {
    loadGorevler();
  }

  Future<void> loadGorevler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllGorev();
      // Tarihe göre sıralama vb. burada yapılabilir
      // result.sort((a, b) => b.kayitZamani.compareTo(a.kayitZamani));
      state = state.copyWith(isLoading: false, gorevler: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER: UI'ın kullanacağı nesne
final gorevNotifierProvider =
    StateNotifierProvider<GorevNotifier, GorevState>((ref) {
  // UseCase'i GetIt (sl) üzerinden çekip Notifier'a veriyoruz
  return GorevNotifier(sl<GetAllGorev>());
});
