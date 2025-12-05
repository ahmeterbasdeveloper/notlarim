import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/durum.dart';

// ✅ Generic UseCase Importu
import '../../../../core/usecases/crud_usecases.dart';

// ✅ Arama UseCase Importu
import '../../domain/usecases/search_durum.dart';

// ✅ DI Provider Dosyası Importu
import 'durum_di_providers.dart';

// -----------------------------------------------------------------------------
// 1. STATE
// -----------------------------------------------------------------------------
class DurumState {
  final List<Durum> durumlar;
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination (Sayfalama) Değişkenleri
  final bool hasMore; // Veritabanında daha fazla veri var mı?
  final int page; // Şu anki sayfa indeksi

  DurumState({
    this.durumlar = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  DurumState copyWith({
    List<Durum>? durumlar,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return DurumState(
      durumlar: durumlar ?? this.durumlar,
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
class DurumNotifier extends StateNotifier<DurumState> {
  // ✅ Generic UseCase Kullanımı
  final GetAllUseCase<Durum> _getAllDurum;

  // ✅ Arama UseCase'i
  final SearchDurum _searchDurum;

  // ✅ Sayfa başına kaç kayıt çekileceği
  final int _pageSize = 20;

  // ✅ Constructor Güncellendi: SearchDurum eklendi
  DurumNotifier(this._getAllDurum, this._searchDurum) : super(DurumState()) {
    loadDurumlar();
  }

  // ✅ Sayfalama Destekli Veri Yükleme Fonksiyonu
  Future<void> loadDurumlar({bool isLoadMore = false}) async {
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
      final result = await _getAllDurum.call(
        limit: _pageSize,
        offset: offset,
      );

      // Gelen veri sayısı limit'ten azsa, listenin sonuna geldik demektir.
      final isLastPage = result.length < _pageSize;

      List<Durum> updatedList;
      if (isLoadMore) {
        // Eski listenin üzerine yenileri ekle
        updatedList = [...state.durumlar, ...result];
      } else {
        // Listeyi sıfırla (Refresh durumu)
        updatedList = result;
      }

      state = state.copyWith(
        isLoading: false,
        durumlar: updatedList,
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
      // Arama boşsa yüklemeyi durdur (veya listeyi resetle)
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // UseCase ile veritabanında arama yap
      final result = await _searchDurum.call(query);

      // Arama sonuçlarını listeye ata
      // Not: Şu an filtered listesi olmadığı için ana listeyi eziyoruz.
      // Bu sayede ekranda sadece arama sonuçları görünür.
      state = state.copyWith(
        isLoading: false,
        durumlar: result,
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
final durumNotifierProvider =
    StateNotifierProvider<DurumNotifier, DurumState>((ref) {
  // Generic provider
  final getAllDurum = ref.watch(getAllDurumProvider);

  // ✅ Arama provider'ı (durum_di_providers.dart dosyasında tanımlı olmalı)
  final searchDurum = ref.watch(searchDurumProvider);

  return DurumNotifier(getAllDurum, searchDurum);
});
