import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/kontrol_liste.dart';

// UseCases
import '../../../../domain/usecases/kontrol_liste/get_all_kontrol_liste.dart';

// DI
import '../../../../core/di/injection_container.dart';

// 1. STATE
class KontrolListeState {
  final List<KontrolListe> kontrolListeleri;
  final bool isLoading;
  final String? errorMessage;

  KontrolListeState({
    this.kontrolListeleri = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KontrolListeState copyWith({
    List<KontrolListe>? kontrolListeleri,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KontrolListeState(
      kontrolListeleri: kontrolListeleri ?? this.kontrolListeleri,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class KontrolListeNotifier extends StateNotifier<KontrolListeState> {
  final GetAllKontrolListe _getAllKontrolListe;

  KontrolListeNotifier(this._getAllKontrolListe) : super(KontrolListeState()) {
    loadKontrolListeleri();
  }

  Future<void> loadKontrolListeleri() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllKontrolListe();
      state = state.copyWith(isLoading: false, kontrolListeleri: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final kontrolListeNotifierProvider =
    StateNotifierProvider<KontrolListeNotifier, KontrolListeState>((ref) {
  return KontrolListeNotifier(sl<GetAllKontrolListe>());
});
