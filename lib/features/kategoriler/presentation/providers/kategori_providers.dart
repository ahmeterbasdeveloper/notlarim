import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/kategori.dart';

// ✅ Generic UseCase Importu
import '../../../../core/usecases/crud_usecases.dart';

// ✅ Arama UseCase Importu
import '../../domain/usecases/search_kategori.dart';

// ✅ DI Providers
import 'kategori_di_providers.dart';

// -----------------------------------------------------------------------------
// 1. STATE
// -----------------------------------------------------------------------------
class KategoriState {
  final List<Kategori> kategoriler;
  final List<Kategori> filteredKategoriler; // Arama için eklendi
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination (Sayfalama) Değişkenleri
  final bool hasMore; // Veritabanında daha fazla veri var mı?
  final int page; // Şu anki sayfa indeksi

  KategoriState({
    this.kategoriler = const [],
    this.filteredKategoriler = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  KategoriState copyWith({
    List<Kategori>? kategoriler,
    List<Kategori>? filteredKategoriler,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return KategoriState(
      kategoriler: kategoriler ?? this.kategoriler,
      filteredKategoriler: filteredKategoriler ?? this.filteredKategoriler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. NOTIFIER
// -----------------------------------------------------------------------------
class KategoriNotifier extends StateNotifier<KategoriState> {
  // Generic UseCase kullanımı
  final GetAllUseCase<Kategori> _getAllKategori;
  // ✅ Arama UseCase'i
  final SearchKategori _searchKategori;

  // ✅ Sayfa başına kaç kayıt çekileceği
  final int _pageSize = 20;

  // ✅ Constructor Güncellendi: SearchKategori eklendi
  KategoriNotifier(this._getAllKategori, this._searchKategori)
      : super(KategoriState()) {
    loadKategoriler();
  }

  // ✅ Sayfalama Destekli Veri Yükleme Fonksiyonu
  Future<void> loadKategoriler({bool isLoadMore = false}) async {
    // Halihazırda yükleniyorsa tekrar istek atma
    if (state.isLoading) return;

    // Daha fazla veri yoksa ve "Daha Fazla Yükle" deniliyorsa dur
    if (isLoadMore && !state.hasMore) return;

    // Yükleniyor durumunu başlat
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Eğer "Load More" ise sayfayı 1 artır, değilse (refresh) 0'dan başla
      final pageToLoad = isLoadMore ? state.page + 1 : 0;
      final offset = pageToLoad * _pageSize;

      // ✅ UseCase çağrısı (Limit ve Offset ile)
      final result = await _getAllKategori.call(
        limit: _pageSize,
        offset: offset,
      );

      // Gelen veri sayısı limit'ten azsa, listenin sonuna geldik demektir.
      final isLastPage = result.length < _pageSize;

      List<Kategori> updatedList;
      if (isLoadMore) {
        // Eski listenin üzerine yenileri ekle
        updatedList = [...state.kategoriler, ...result];
      } else {
        // Listeyi sıfırla (Refresh durumu)
        updatedList = result;
      }

      state = state.copyWith(
        isLoading: false,
        kategoriler: updatedList,
        // Filtreli listeyi de ana liste ile eşitle (Arama sıfırlanır)
        filteredKategoriler: updatedList,
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
      state = state.copyWith(filteredKategoriler: state.kategoriler);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // UseCase ile veritabanında arama yap
      final result = await _searchKategori.call(query);

      state = state.copyWith(
        isLoading: false,
        filteredKategoriler: result, // Sonuçları güncelle
      );
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: "Arama hatası: $e");
    }
  }

  // 🔍 Yerel Arama / Filtreleme Fonksiyonu (Opsiyonel olarak kalabilir)
  void filterLocalKategoriler(String query) {
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

// -----------------------------------------------------------------------------
// 3. PROVIDER
// -----------------------------------------------------------------------------
final kategoriNotifierProvider =
    StateNotifierProvider<KategoriNotifier, KategoriState>((ref) {
  // Generic provider'ı çağırıyoruz
  final getAllKategori = ref.watch(getAllKategoriProvider);

  // ✅ Arama provider'ını çağırıyoruz (kategori_di_providers.dart içinde tanımladık)
  final searchKategori = ref.watch(searchKategoriProvider);

  return KategoriNotifier(getAllKategori, searchKategori);
});
