import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:notlarim/core/usecases/crud_usecases.dart';
import '../../domain/entities/not.dart';
// Domain UseCases

import '../../domain/usecases/search_not.dart';

// Dependency Injection
import 'not_di_providers.dart';

// 1. STATE
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

// 2. NOTIFIER
class NotNotifier extends StateNotifier<NotState> {
  final GetAllUseCase<Not> _getAllNot; // Generic UseCase
  final SearchNot _searchNot;

  NotNotifier(this._getAllNot, this._searchNot) : super(NotState()) {
    loadNotlar();
  }

  // Notları veritabanından çekme
  Future<void> loadNotlar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllNot.call();
      state = state.copyWith(
        isLoading: false,
        notlar: result,
        filteredNotlar: result, // İlk başta hepsi görünür
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ✅ EKSİK OLAN METOD BURAYA EKLENDİ
  // Yerel arama (RAM üzerinde hızlı filtreleme)
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

  // Veritabanı araması (Opsiyonel)
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

// 3. PROVIDER
final notNotifierProvider = StateNotifierProvider<NotNotifier, NotState>((ref) {
  final getAllNot = ref.watch(getAllNotProvider);
  final searchNot = ref.watch(searchNotProvider);

  return NotNotifier(getAllNot, searchNot);
});
