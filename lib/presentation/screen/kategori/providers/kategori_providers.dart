import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/kategori.dart';

// UseCases
import '../../../../domain/usecases/kategori/get_all_kategori.dart';

// DI
import '../../../../core/di/injection_container.dart';

// 1. STATE
class KategoriState {
  final List<Kategori> kategoriler;
  final bool isLoading;
  final String? errorMessage;

  KategoriState({
    this.kategoriler = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KategoriState copyWith({
    List<Kategori>? kategoriler,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KategoriState(
      kategoriler: kategoriler ?? this.kategoriler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class KategoriNotifier extends StateNotifier<KategoriState> {
  final GetAllKategori _getAllKategori;

  KategoriNotifier(this._getAllKategori) : super(KategoriState()) {
    loadKategoriler();
  }

  Future<void> loadKategoriler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllKategori();
      state = state.copyWith(isLoading: false, kategoriler: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final kategoriNotifierProvider =
    StateNotifierProvider<KategoriNotifier, KategoriState>((ref) {
  return KategoriNotifier(sl<GetAllKategori>());
});
