import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/hatirlatici.dart';

// ✅ Generic UseCase
import '../../../../core/usecases/crud_usecases.dart';
// ✅ Arama UseCase
import '../../domain/usecases/search_hatirlatici.dart';
// ✅ DI Providers
import 'hatirlatici_di_providers.dart';

// 1. STATE
class HatirlaticiState {
  final List<Hatirlatici> hatirlaticilar;
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination Değişkenleri
  final bool hasMore;
  final int page;

  HatirlaticiState({
    this.hatirlaticilar = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  HatirlaticiState copyWith({
    List<Hatirlatici>? hatirlaticilar,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return HatirlaticiState(
      hatirlaticilar: hatirlaticilar ?? this.hatirlaticilar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// 2. NOTIFIER
class HatirlaticiNotifier extends StateNotifier<HatirlaticiState> {
  final GetAllUseCase<Hatirlatici> _getAllHatirlatici;
  final SearchHatirlatici _searchHatirlatici; // ✅ Eklendi

  final int _pageSize = 20;

  HatirlaticiNotifier(this._getAllHatirlatici, this._searchHatirlatici)
      : super(HatirlaticiState()) {
    loadHatirlaticilar();
  }

  // ✅ Sayfalama Destekli Yükleme
  Future<void> loadHatirlaticilar({bool isLoadMore = false}) async {
    if (state.isLoading) return;
    if (isLoadMore && !state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final pageToLoad = isLoadMore ? state.page + 1 : 0;
      final offset = pageToLoad * _pageSize;

      final result =
          await _getAllHatirlatici.call(limit: _pageSize, offset: offset);

      final isLastPage = result.length < _pageSize;

      List<Hatirlatici> updatedList;
      if (isLoadMore) {
        updatedList = [...state.hatirlaticilar, ...result];
      } else {
        updatedList = result;
      }

      // Tarihe göre sıralama (İsteğe bağlı)
      updatedList.sort((a, b) =>
          a.hatirlatmaTarihiZamani.compareTo(b.hatirlatmaTarihiZamani));

      state = state.copyWith(
        isLoading: false,
        hatirlaticilar: updatedList,
        hasMore: !isLastPage,
        page: pageToLoad,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ✅ Veritabanı Arama Fonksiyonu
  Future<void> searchFromDb(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(isLoading: false);
      // İsteğe bağlı: loadHatirlaticilar() çağırarak listeyi resetleyebilirsiniz.
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final result = await _searchHatirlatici.call(query);

      // Arama sonuçlarını da sıralayalım
      result.sort((a, b) =>
          a.hatirlatmaTarihiZamani.compareTo(b.hatirlatmaTarihiZamani));

      state = state.copyWith(
        isLoading: false,
        hatirlaticilar: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. PROVIDER
final hatirlaticiNotifierProvider =
    StateNotifierProvider<HatirlaticiNotifier, HatirlaticiState>((ref) {
  final getAll = ref.watch(getAllHatirlaticiProvider);
  final search = ref.watch(searchHatirlaticiProvider); // ✅
  return HatirlaticiNotifier(getAll, search);
});
