import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/hatirlatici.dart';

// UseCases
import '../../../../domain/usecases/hatirlatici/get_all_hatirlatici.dart';

// DI
import '../../../../core/di/injection_container.dart';

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
  final GetAllHatirlatici _getAllHatirlatici;

  HatirlaticiNotifier(this._getAllHatirlatici) : super(HatirlaticiState()) {
    loadHatirlaticilar();
  }

  Future<void> loadHatirlaticilar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllHatirlatici();
      state = state.copyWith(isLoading: false, hatirlaticilar: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final hatirlaticiNotifierProvider =
    StateNotifierProvider<HatirlaticiNotifier, HatirlaticiState>((ref) {
  return HatirlaticiNotifier(sl<GetAllHatirlatici>());
});
