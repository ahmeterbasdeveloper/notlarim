import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/durum.dart';

// UseCases
import '../../../../domain/usecases/durum/get_all_durum.dart';

// DI
import '../../../../core/di/injection_container.dart';

// 1. STATE
class DurumState {
  final List<Durum> durumlar;
  final bool isLoading;
  final String? errorMessage;

  DurumState({
    this.durumlar = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DurumState copyWith({
    List<Durum>? durumlar,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DurumState(
      durumlar: durumlar ?? this.durumlar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class DurumNotifier extends StateNotifier<DurumState> {
  final GetAllDurum _getAllDurum;

  DurumNotifier(this._getAllDurum) : super(DurumState()) {
    loadDurumlar();
  }

  Future<void> loadDurumlar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllDurum();
      state = state.copyWith(isLoading: false, durumlar: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final durumNotifierProvider =
    StateNotifierProvider<DurumNotifier, DurumState>((ref) {
  return DurumNotifier(sl<GetAllDurum>());
});
