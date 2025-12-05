import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/gorev.dart';

// ✅ Generic UseCase
import '../../../../core/usecases/crud_usecases.dart';
// ✅ Arama UseCase
import '../../domain/usecases/search_gorev.dart';
// ✅ DI Providers
import 'gorev_di_providers.dart';

// STATE
class GorevState {
  final List<Gorev> gorevler;
  final bool isLoading;
  final String? errorMessage;
  // ✅ Pagination
  final bool hasMore;
  final int page;

  GorevState({
    this.gorevler = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  GorevState copyWith({
    List<Gorev>? gorevler,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return GorevState(
      gorevler: gorevler ?? this.gorevler,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// NOTIFIER
class GorevNotifier extends StateNotifier<GorevState> {
  final GetAllUseCase<Gorev> _getAllGorev;
  final SearchGorev _searchGorev; // ✅ Eklendi

  final int _pageSize = 20;

  GorevNotifier(this._getAllGorev, this._searchGorev) : super(GorevState()) {
    loadGorevler();
  }

  // ✅ Sayfalama Destekli Yükleme
  Future<void> loadGorevler({bool isLoadMore = false}) async {
    if (state.isLoading) return;
    if (isLoadMore && !state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final pageToLoad = isLoadMore ? state.page + 1 : 0;
      final offset = pageToLoad * _pageSize;

      final result = await _getAllGorev.call(limit: _pageSize, offset: offset);

      final isLastPage = result.length < _pageSize;

      List<Gorev> updatedList;
      if (isLoadMore) {
        updatedList = [...state.gorevler, ...result];
      } else {
        updatedList = result;
      }

      updatedList.sort(
          (a, b) => a.baslamaTarihiZamani.compareTo(b.baslamaTarihiZamani));

      state = state.copyWith(
        isLoading: false,
        gorevler: updatedList,
        hasMore: !isLastPage,
        page: pageToLoad,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ✅ Veritabanı Arama
  Future<void> searchFromDb(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final result = await _searchGorev.call(query);

      // Arama sonuçlarını sırala
      result.sort(
          (a, b) => a.baslamaTarihiZamani.compareTo(b.baslamaTarihiZamani));

      state = state.copyWith(
        isLoading: false,
        gorevler: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// PROVIDER
final gorevNotifierProvider =
    StateNotifierProvider<GorevNotifier, GorevState>((ref) {
  final getAll = ref.watch(getAllGorevProvider);
  final search = ref.watch(searchGorevProvider); // ✅
  return GorevNotifier(getAll, search);
});
