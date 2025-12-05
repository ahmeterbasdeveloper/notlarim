import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:notlarim/features/oncelik/presentation/providers/oncelik_di_providers.dart';

// Entities
import '../../domain/entities/kontrol_liste.dart';

// ✅ Generic UseCase
import '../../../../core/usecases/crud_usecases.dart';

// ✅ Arama UseCase Importu
import '../../domain/usecases/search_kontrol_liste.dart';

// ✅ DI Providers
import 'kontrol_liste_di_providers.dart';

// ✅ Helper & Utils (Öncelik Rengi İçin)
import '../../../../core/utils/color_helper.dart';

// =============================================================================
// 🎨 ÖNCELİK RENGİ PROVIDER'I (Aynen Kalabilir)
// =============================================================================
final oncelikColorProvider =
    FutureProvider.family<Color, int>((ref, oncelikId) async {
  try {
    // ✅ UseCase'i Riverpod'dan çekiyoruz
    final getOncelikById = ref.read(getOncelikByIdProvider);

    // Veriyi istiyoruz
    final oncelik = await getOncelikById.call(oncelikId);

    if (oncelik != null && oncelik.renkKodu.isNotEmpty) {
      return ColorHelper.hexToColor(oncelik.renkKodu);
    }
    return Colors.grey.shade300;
  } catch (e) {
    return Colors.grey.shade300;
  }
});

// =============================================================================
// 📋 LİSTE STATE YÖNETİMİ
// =============================================================================

// 1. STATE
class KontrolListeState {
  final List<KontrolListe> kontrolListeleri;
  final bool isLoading;
  final String? errorMessage;

  // ✅ Pagination (Sayfalama) Değişkenleri
  final bool hasMore; // Veritabanında daha fazla veri var mı?
  final int page; // Şu anki sayfa indeksi

  KontrolListeState({
    this.kontrolListeleri = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.page = 0,
  });

  KontrolListeState copyWith({
    List<KontrolListe>? kontrolListeleri,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return KontrolListeState(
      kontrolListeleri: kontrolListeleri ?? this.kontrolListeleri,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// 2. NOTIFIER
class KontrolListeNotifier extends StateNotifier<KontrolListeState> {
  // Generic UseCase
  final GetAllUseCase<KontrolListe> _getAllKontrolListe;

  // ✅ Arama UseCase'i
  final SearchKontrolListe _searchKontrolListe;

  // ✅ Sayfa başına kaç kayıt çekileceği
  final int _pageSize = 20;

  // ✅ Constructor Güncellendi: SearchKontrolListe eklendi
  KontrolListeNotifier(this._getAllKontrolListe, this._searchKontrolListe)
      : super(KontrolListeState()) {
    loadKontrolListeleri();
  }

  // ✅ Sayfalama Destekli Veri Yükleme Fonksiyonu
  Future<void> loadKontrolListeleri({bool isLoadMore = false}) async {
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
      final result = await _getAllKontrolListe.call(
        limit: _pageSize,
        offset: offset,
      );

      // Gelen veri sayısı limit'ten azsa, listenin sonuna geldik demektir.
      final isLastPage = result.length < _pageSize;

      List<KontrolListe> updatedList;
      if (isLoadMore) {
        // Eski listenin üzerine yenileri ekle
        updatedList = [...state.kontrolListeleri, ...result];
      } else {
        // Listeyi sıfırla (Refresh durumu)
        updatedList = result;
      }

      state = state.copyWith(
        isLoading: false,
        kontrolListeleri: updatedList,
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
      // Arama boşsa yüklemeyi durdur (veya UI'dan loadKontrolListeleri çağrılır)
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // UseCase ile veritabanında arama yap
      final result = await _searchKontrolListe.call(query);

      state = state.copyWith(
        isLoading: false,
        kontrolListeleri: result, // Sonuçları listeye ata
      );
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: "Arama hatası: $e");
    }
  }
}

// 3. PROVIDER
final kontrolListeNotifierProvider =
    StateNotifierProvider<KontrolListeNotifier, KontrolListeState>((ref) {
  // Generic Provider
  final getAll = ref.watch(getAllKontrolListeProvider);

  // ✅ Arama Provider'ı (kontrol_liste_di_providers.dart'tan gelir)
  final search = ref.watch(searchKontrolListeProvider);

  return KontrolListeNotifier(getAll, search);
});
