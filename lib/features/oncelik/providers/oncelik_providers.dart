import 'package:flutter_riverpod/legacy.dart';
import '../domain/entities/oncelik.dart';

// ✅ 1. Generic UseCase Importu (GetAllOncelik yerine bunu kullanıyoruz)
import '../../../core/usecases/crud_usecases.dart';

// ✅ 2. DI Provider'larına erişim
import 'oncelik_di_providers.dart';

// -----------------------------------------------------------------------------
// 1. STATE (Veri Durumu)
// -----------------------------------------------------------------------------
class OncelikState {
  final List<Oncelik> oncelikler;
  final List<Oncelik> filteredOncelikler; // Arama/Filtreleme için
  final bool isLoading;
  final String? errorMessage;

  OncelikState({
    this.oncelikler = const [],
    this.filteredOncelikler = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OncelikState copyWith({
    List<Oncelik>? oncelikler,
    List<Oncelik>? filteredOncelikler,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OncelikState(
      oncelikler: oncelikler ?? this.oncelikler,
      filteredOncelikler: filteredOncelikler ?? this.filteredOncelikler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. NOTIFIER (İş Mantığı)
// -----------------------------------------------------------------------------
class OncelikNotifier extends StateNotifier<OncelikState> {
  // ✅ Generic UseCase Tanımı
  final GetAllUseCase<Oncelik> _getAllOncelik;

  OncelikNotifier(this._getAllOncelik) : super(OncelikState()) {
    loadOncelikler();
  }

  /// Veritabanından tüm öncelikleri çeker
  Future<void> loadOncelikler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // ✅ UseCase çağrısı
      final result = await _getAllOncelik.call();

      state = state.copyWith(
        isLoading: false,
        oncelikler: result,
        filteredOncelikler: result, // Başlangıçta hepsi görünür
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 🔎 Arama / Filtreleme Fonksiyonu
  void filterOncelikler(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredOncelikler: state.oncelikler);
    } else {
      final searchLower = _replaceTurkishChars(query.trim());
      final filtered = state.oncelikler.where((oncelik) {
        final baslikLower = _replaceTurkishChars(oncelik.baslik);
        final aciklamaLower = _replaceTurkishChars(oncelik.aciklama);
        return baslikLower.contains(searchLower) ||
            aciklamaLower.contains(searchLower);
      }).toList();
      state = state.copyWith(filteredOncelikler: filtered);
    }
  }

  String _replaceTurkishChars(String input) {
    if (input.isEmpty) return "";
    return input
        .toLowerCase()
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('i', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }
}

// -----------------------------------------------------------------------------
// 3. PROVIDER (UI'ın Eriştiği Nokta)
// -----------------------------------------------------------------------------
final oncelikNotifierProvider =
    StateNotifierProvider<OncelikNotifier, OncelikState>((ref) {
  // app_providers.dart dosyasındaki Generic Provider'ı okuyoruz
  final getAllOncelik = ref.watch(getAllOncelikProvider);

  return OncelikNotifier(getAllOncelik);
});
