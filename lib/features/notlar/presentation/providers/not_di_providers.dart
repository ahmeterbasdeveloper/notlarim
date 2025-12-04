import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';
import '../../../../../../core/di/core_providers.dart';
import '../../../../../../core/usecases/crud_usecases.dart';

// Bağımlı olduğu diğer modüller

import '../../domain/entities/not.dart';
import '../../domain/repositories/not_repository.dart';
import '../../data/repositories/not_repository_impl.dart';

// Özel UseCase'ler
import '../../domain/usecases/search_not.dart';
import '../../domain/usecases/get_not_by_kategori.dart';
import '../../domain/usecases/get_not_by_durum.dart';
import '../../domain/usecases/get_not_by_oncelik.dart';

// REPOSITORY
final notRepositoryProvider = Provider<NotRepository>((ref) {
  return NotRepositoryImpl(
    ref.watch(dbServiceProvider),
    // Diğer provider dosyalarından gelen providerları okuyoruz
    kategoriRepository: ref.watch(kategoriRepositoryProvider),
    oncelikRepository: ref.watch(oncelikRepositoryProvider),
  );
});

// USECASES
final getAllNotProvider =
    Provider((ref) => GetAllUseCase<Not>(ref.watch(notRepositoryProvider)));

final createNotProvider =
    Provider((ref) => CreateUseCase<Not>(ref.watch(notRepositoryProvider)));

final updateNotProvider =
    Provider((ref) => UpdateUseCase<Not>(ref.watch(notRepositoryProvider)));

final deleteNotProvider =
    Provider((ref) => DeleteUseCase<Not>(ref.watch(notRepositoryProvider)));

final getNotByIdProvider =
    Provider((ref) => GetByIdUseCase<Not>(ref.watch(notRepositoryProvider)));

// ÖZEL USECASES
final searchNotProvider =
    Provider((ref) => SearchNot(ref.watch(notRepositoryProvider)));

final getNotByKategoriProvider =
    Provider((ref) => GetNotByKategori(ref.watch(notRepositoryProvider)));

final getNotByDurumProvider =
    Provider((ref) => GetNotByDurum(ref.watch(notRepositoryProvider)));

final getNotByOncelikProvider =
    Provider((ref) => GetNotByOncelik(ref.watch(notRepositoryProvider)));
