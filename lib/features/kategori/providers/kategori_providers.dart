import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../domain/entities/kategori.dart';

// ✅ Generic UseCase Importu
import '../../../core/usecases/crud_usecases.dart';

// ✅ DI Providers
import 'kategori_di_providers.dart';

// 1. STATE
class KategoriState {
  final List<Kategori> kategoriler;
  final List<Kategori> filteredKategoriler; // Arama için eklendi
  final bool isLoading;
  final String? errorMessage;

  KategoriState({
    this.kategoriler = const [],
    this.filteredKategoriler = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KategoriState copyWith({
    List<Kategori>? kategoriler,
    List<Kategori>? filteredKategoriler,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KategoriState(
      kategoriler: kategoriler ?? this.kategoriler,
      filteredKategoriler: filteredKategoriler ?? this.filteredKategoriler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER
class KategoriNotifier extends StateNotifier<KategoriState> {
  // Generic UseCase kullanımı
  final GetAllUseCase<Kategori> _getAllKategori;

  KategoriNotifier(this._getAllKategori) : super(KategoriState()) {
    loadKategoriler();
  }

  Future<void> loadKategoriler() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllKategori.call();
      state = state.copyWith(
        isLoading: false,
        kategoriler: result,
        filteredKategoriler: result, // Başlangıçta hepsi görünür
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 🔍 Yerel Arama / Filtreleme Fonksiyonu
  void filterKategoriler(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredKategoriler: state.kategoriler);
    } else {
      final searchLower = _replaceTurkishChars(query.trim());
      final filtered = state.kategoriler.where((kategori) {
        final baslikLower = _replaceTurkishChars(kategori.baslik);
        final aciklamaLower = _replaceTurkishChars(kategori.aciklama);
        return baslikLower.contains(searchLower) ||
            aciklamaLower.contains(searchLower);
      }).toList();
      state = state.copyWith(filteredKategoriler: filtered);
    }
  }

  // Türkçe karakter dönüşümü (Helper)
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

// 3. PROVIDER
final kategoriNotifierProvider =
    StateNotifierProvider<KategoriNotifier, KategoriState>((ref) {
  // app_providers.dart dosyasındaki generic provider'ı çağırıyoruz
  final getAllKategori = ref.watch(getAllKategoriProvider);
  return KategoriNotifier(getAllKategori);
});
