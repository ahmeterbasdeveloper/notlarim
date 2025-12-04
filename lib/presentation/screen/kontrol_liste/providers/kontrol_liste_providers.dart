import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/core/di/oncelik_di_providers.dart';

// Entities
import '../../../../domain/entities/kontrol_liste.dart';

// ✅ Generic UseCase
import '../../../../core/usecases/crud_usecases.dart';
// ✅ DI Providers
import '../../../../core/di/kontrol_liste_di_providers.dart';

// ✅ Helper & Utils (Öncelik Rengi İçin)
import '../../../../core/utils/color_helper.dart';

// =============================================================================
// 🎨 ÖNCELİK RENGİ PROVIDER'I (Aynen Kalabilir, ama sl yerine ref kullanalım)
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

// STATE
class KontrolListeState {
  final List<KontrolListe> kontrolListeleri;
  final bool isLoading;
  final String? errorMessage;

  KontrolListeState({
    this.kontrolListeleri = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KontrolListeState copyWith({
    List<KontrolListe>? kontrolListeleri,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KontrolListeState(
      kontrolListeleri: kontrolListeleri ?? this.kontrolListeleri,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// NOTIFIER
class KontrolListeNotifier extends StateNotifier<KontrolListeState> {
  final GetAllUseCase<KontrolListe> _getAllKontrolListe;

  KontrolListeNotifier(this._getAllKontrolListe) : super(KontrolListeState()) {
    loadKontrolListeleri();
  }

  Future<void> loadKontrolListeleri() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _getAllKontrolListe.call();
      // Sıralama (Opsiyonel)
      // result.sort((a, b) => b.kayitZamani.compareTo(a.kayitZamani));
      state = state.copyWith(isLoading: false, kontrolListeleri: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// PROVIDER
final kontrolListeNotifierProvider =
    StateNotifierProvider<KontrolListeNotifier, KontrolListeState>((ref) {
  // Generic Provider
  final getAll = ref.watch(getAllKontrolListeProvider);
  return KontrolListeNotifier(getAll);
});
