import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/di/core_providers.dart'; // DB Provider buradan geliyor
import '../../../../../core/usecases/crud_usecases.dart';

import '../domain/entities/kategori.dart';
import '../domain/repositories/kategori_repository.dart';
import '../data/repositories/kategori_repository_impl.dart';
import '../domain/usecases/get_first_kategori.dart';

// REPOSITORY
final kategoriRepositoryProvider = Provider<KategoriRepository>((ref) {
  return KategoriRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllKategoriProvider = Provider(
    (ref) => GetAllUseCase<Kategori>(ref.watch(kategoriRepositoryProvider)));

final createKategoriProvider = Provider(
    (ref) => CreateUseCase<Kategori>(ref.watch(kategoriRepositoryProvider)));

final updateKategoriProvider = Provider(
    (ref) => UpdateUseCase<Kategori>(ref.watch(kategoriRepositoryProvider)));

final deleteKategoriProvider = Provider(
    (ref) => DeleteUseCase<Kategori>(ref.watch(kategoriRepositoryProvider)));

final getKategoriByIdProvider = Provider(
    (ref) => GetByIdUseCase<Kategori>(ref.watch(kategoriRepositoryProvider)));

final getFirstKategoriProvider =
    Provider((ref) => GetFirstKategori(ref.watch(kategoriRepositoryProvider)));
