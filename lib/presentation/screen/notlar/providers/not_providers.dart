import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/not.dart';

// Domain UseCases
import '../../../../domain/usecases/not/get_all_not.dart';
import '../../../../domain/usecases/not/search_not.dart';

// Dependency Injection (sl'i buradan alacağız)
import '../../../../core/di/injection_container.dart';

// 1. STATE: UI'ın ihtiyaç duyduğu verilerin durumu
class NotState {
  final List<Not> notlar;
  final List<Not> filteredNotlar;
  final bool isLoading;
  final String? errorMessage;

  NotState({
    this.notlar = const [],
    this.filteredNotlar = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotState copyWith({
    List<Not>? notlar,
    List<Not>? filteredNotlar,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotState(
      notlar: notlar ?? this.notlar,
      filteredNotlar: filteredNotlar ?? this.filteredNotlar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 2. NOTIFIER: İş Mantığı (Logic)
class NotNotifier extends StateNotifier<NotState> {
  final GetAllNot _getAllNot;
  final SearchNot _searchNot;

  NotNotifier(this._getAllNot, this._searchNot) : super(NotState()) {
    loadNotlar();
  }

  // Notları veritabanından çekme
  Future<void> loadNotlar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllNot();
      state = state.copyWith(
        isLoading: false,
        notlar: result,
        filteredNotlar: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Yerel arama (RAM üzerinde hızlı filtreleme)
  void filterLocalNotes(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredNotlar: state.notlar);
      return;
    }
    final filtered = state.notlar.where((not) {
      final baslik = not.baslik.toLowerCase();
      final aciklama = not.aciklama.toLowerCase();
      final q = query.toLowerCase();
      return baslik.contains(q) || aciklama.contains(q);
    }).toList();

    state = state.copyWith(filteredNotlar: filtered);
  }

  // Veritabanı araması
  Future<void> searchFromDb(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(filteredNotlar: state.notlar);
      return;
    }
    try {
      final result = await _searchNot(query);
      state = state.copyWith(filteredNotlar: result);
    } catch (e) {
      state = state.copyWith(errorMessage: "Arama hatası: $e");
    }
  }
}

// 3. PROVIDER: HATA ALDIĞINIZ KISIM BURASIYDI - DÜZELTİLDİ
final notNotifierProvider = StateNotifierProvider<NotNotifier, NotState>((ref) {
  // "sl" (Service Locator) kullanarak gerekli UseCase'leri çekiyoruz.
  // injection_container.dart dosyasında bunları kaydetmiştik.
  final getAllNot = sl<GetAllNot>();
  final searchNot = sl<SearchNot>();

  return NotNotifier(getAllNot, searchNot);
});
