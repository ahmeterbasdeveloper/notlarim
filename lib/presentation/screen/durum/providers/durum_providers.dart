import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/durum.dart';

// ✅ 1. Generic UseCase Importu
import '../../../../core/usecases/crud_usecases.dart';

// ✅ 2. DI Provider Dosyası Importu (GetIt yerine)
import '../../../../core/di/durum_di_providers.dart';

// 1. STATE (Değişiklik Yok)
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
  // ✅ Generic UseCase Kullanımı
  final GetAllUseCase<Durum> _getAllDurum;

  DurumNotifier(this._getAllDurum) : super(DurumState()) {
    loadDurumlar();
  }

  Future<void> loadDurumlar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // ✅ UseCase çağrısı
      final result = await _getAllDurum.call();
      state = state.copyWith(isLoading: false, durumlar: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final durumNotifierProvider =
    StateNotifierProvider<DurumNotifier, DurumState>((ref) {
  final getAllDurum = ref.watch(getAllDurumProvider);

  return DurumNotifier(getAllDurum);
});
