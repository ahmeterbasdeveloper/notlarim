import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/oncelik.dart';

// ✅ Generic UseCase Importu
import '../../../../core/usecases/crud_usecases.dart';

// ✅ Arama UseCase Importu
import '../../domain/usecases/search_oncelik.dart';

// ✅ DI Provider'larına erişim
import 'oncelik_di_providers.dart';

// -----------------------------------------------------------------------------
// 1. STATE (Veri Durumu)
// -----------------------------------------------------------------------------
class OncelikState {
  final List<Oncelik> oncelikler;
  final List<Oncelik> filteredOncelikler; // Arama/Filtreleme için
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination (Sayfalama) Değişkenleri
  final bool hasMore; // Veritabanında daha fazla veri var mı?
  final int page; // Şu anki sayfa indeksi

  OncelikState({
    this.oncelikler = const [],
    this.filteredOncelikler = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  OncelikState copyWith({
    List<Oncelik>? oncelikler,
    List<Oncelik>? filteredOncelikler,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return OncelikState(
      oncelikler: oncelikler ?? this.oncelikler,
      filteredOncelikler: filteredOncelikler ?? this.filteredOncelikler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. NOTIFIER (İş Mantığı)
// -----------------------------------------------------------------------------
class OncelikNotifier extends StateNotifier<OncelikState> {
  // ✅ Generic UseCase Tanımı
  final GetAllUseCase<Oncelik> _getAllOncelik;

  // ✅ Arama UseCase Tanımı
  final SearchOncelik _searchOncelik;

  // ✅ Sayfa başına kaç kayıt çekileceği
  final int _pageSize = 20;

  // ✅ Constructor Güncellendi: SearchOncelik eklendi
  OncelikNotifier(this._getAllOncelik, this._searchOncelik)
      : super(OncelikState()) {
    loadOncelikler();
  }

  /// Veritabanından öncelikleri çeker (Sayfalama destekli)
  Future<void> loadOncelikler({bool isLoadMore = false}) async {
    // Halihazırda yükleniyorsa tekrar istek atma
    if (state.isLoading) return;

    // Daha fazla veri yoksa ve "Daha Fazla Yükle" deniliyorsa dur
    if (isLoadMore && !state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Eğer "Load More" ise sayfayı 1 artır, değilse (refresh) 0'dan başla
      final pageToLoad = isLoadMore ? state.page + 1 : 0;
      final offset = pageToLoad * _pageSize;

      // ✅ UseCase çağrısı (Limit ve Offset ile)
      final result =
          await _getAllOncelik.call(limit: _pageSize, offset: offset);

      // Gelen veri sayısı limit'ten azsa, listenin sonuna geldik demektir.
      final isLastPage = result.length < _pageSize;

      List<Oncelik> updatedList;
      if (isLoadMore) {
        // Eski listenin üzerine yenileri ekle
        updatedList = [...state.oncelikler, ...result];
      } else {
        // Listeyi sıfırla (Refresh durumu)
        updatedList = result;
      }

      state = state.copyWith(
        isLoading: false,
        oncelikler: updatedList,
        // Filtreli listeyi de ana liste ile eşitle (Arama sıfırlanır)
        filteredOncelikler: updatedList,
        hasMore: !isLastPage,
        page: pageToLoad,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ✅ Veritabanından Arama Fonksiyonu (Eksik olan buydu)
  Future<void> searchFromDb(String query) async {
    if (query.isEmpty) {
      // Arama boşsa mevcut yüklü listeye dön
      state = state.copyWith(filteredOncelikler: state.oncelikler);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // UseCase ile veritabanında arama yap
      final result = await _searchOncelik.call(query);

      state = state.copyWith(
        isLoading: false,
        filteredOncelikler: result, // Sonuçları güncelle
      );
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: "Arama hatası: $e");
    }
  }

  /// 🔎 Yerel Arama / Filtreleme Fonksiyonu (Opsiyonel olarak kalabilir)
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

  // ✅ Arama Provider'ını okuyoruz (oncelik_di_providers.dart'tan gelir)
  final searchOncelik = ref.watch(searchOncelikProvider);

  return OncelikNotifier(getAllOncelik, searchOncelik);
});
