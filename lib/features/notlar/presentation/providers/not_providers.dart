import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/not.dart';

// ✅ Generic UseCase Importu
import '../../../../core/usecases/crud_usecases.dart';

// Domain UseCases
import '../../domain/usecases/search_not.dart';

// Dependency Injection
import 'not_di_providers.dart';

// -----------------------------------------------------------------------------
// 1. STATE
// -----------------------------------------------------------------------------
class NotState {
  final List<Not> notlar;
  final List<Not> filteredNotlar;
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination (Sayfalama) Değişkenleri
  final bool hasMore; // Veritabanında daha fazla veri var mı?
  final int page; // Şu anki sayfa indeksi

  NotState({
    this.notlar = const [],
    this.filteredNotlar = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  NotState copyWith({
    List<Not>? notlar,
    List<Not>? filteredNotlar,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return NotState(
      notlar: notlar ?? this.notlar,
      filteredNotlar: filteredNotlar ?? this.filteredNotlar,
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
class NotNotifier extends StateNotifier<NotState> {
  final GetAllUseCase<Not> _getAllNot; // Generic UseCase
  final SearchNot _searchNot;

  // ✅ Sayfa başına kaç not çekileceğini belirleyen sabit
  final int _pageSize = 20;

  NotNotifier(this._getAllNot, this._searchNot) : super(NotState()) {
    // İlk açılışta verileri yükle
    loadNotlar();
  }

  // ✅ Sayfalama Destekli Veri Yükleme Fonksiyonu
  Future<void> loadNotlar({bool isLoadMore = false}) async {
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
      final result = await _getAllNot.call(limit: _pageSize, offset: offset);

      // Gelen veri sayısı limit'ten azsa, listenin sonuna geldik demektir.
      final isLastPage = result.length < _pageSize;

      List<Not> updatedList;
      if (isLoadMore) {
        // Eski listenin üzerine yenileri ekle
        updatedList = [...state.notlar, ...result];
      } else {
        // Listeyi sıfırla (Refresh durumu)
        updatedList = result;
      }

      state = state.copyWith(
        isLoading: false,
        notlar: updatedList,
        // Filtreli listeyi de ana liste ile eşitle (Arama sıfırlanır)
        filteredNotlar: updatedList,
        hasMore: !isLastPage,
        page: pageToLoad,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 🔍 Yerel arama (RAM üzerindeki yüklü verilerde hızlı filtreleme)
  void filterLocalNotes(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredNotlar: state.notlar);
    } else {
      final lowerQuery = query.toLowerCase();
      final filtered = state.notlar.where((not) {
        final baslik = not.baslik.toLowerCase();
        final aciklama = not.aciklama.toLowerCase();
        return baslik.contains(lowerQuery) || aciklama.contains(lowerQuery);
      }).toList();

      state = state.copyWith(filteredNotlar: filtered);
    }
  }

  // 🔍 Veritabanı araması (Tüm DB içinde arama yapar)
  Future<void> searchFromDb(String query) async {
    if (query.isEmpty) {
      // Arama boşsa mevcut yüklü listeye dön
      state = state.copyWith(filteredNotlar: state.notlar);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final result = await _searchNot(query);
      state = state.copyWith(
        isLoading: false,
        filteredNotlar: result,
      );
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: "Arama hatası: $e");
    }
  }
}

// -----------------------------------------------------------------------------
// 3. PROVIDER
// -----------------------------------------------------------------------------
final notNotifierProvider = StateNotifierProvider<NotNotifier, NotState>((ref) {
  final getAllNot = ref.watch(getAllNotProvider);
  final searchNot = ref.watch(searchNotProvider);

  return NotNotifier(getAllNot, searchNot);
});
