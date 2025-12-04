import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../domain/entities/hatirlatici.dart';

// ✅ Generic UseCase
import '../../../core/usecases/crud_usecases.dart';
// ✅ DI Providers
import '../presentation/providers/hatirlatici_di_providers.dart';

// 1. STATE
class HatirlaticiState {
  final List<Hatirlatici> hatirlaticilar;
  final bool isLoading;
  final String? errorMessage;

  HatirlaticiState({
    this.hatirlaticilar = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HatirlaticiState copyWith({
    List<Hatirlatici>? hatirlaticilar,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HatirlaticiState(
      hatirlaticilar: hatirlaticilar ?? this.hatirlaticilar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class HatirlaticiNotifier extends StateNotifier<HatirlaticiState> {
  final GetAllUseCase<Hatirlatici> _getAllHatirlatici;

  HatirlaticiNotifier(this._getAllHatirlatici) : super(HatirlaticiState()) {
    loadHatirlaticilar();
  }

  Future<void> loadHatirlaticilar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllHatirlatici.call();
      // İsterseniz tarihe göre sıralayabilirsiniz
      result.sort((a, b) =>
          a.hatirlatmaTarihiZamani.compareTo(b.hatirlatmaTarihiZamani));

      state = state.copyWith(isLoading: false, hatirlaticilar: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final hatirlaticiNotifierProvider =
    StateNotifierProvider<HatirlaticiNotifier, HatirlaticiState>((ref) {
  final getAll = ref.watch(getAllHatirlaticiProvider);
  return HatirlaticiNotifier(getAll);
});
