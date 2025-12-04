import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/usecases/crud_usecases.dart';

import '../../../../domain/entities/oncelik.dart';
import '../../../../domain/repositories/oncelik_repository.dart';
import '../../../../data/repositories/oncelik_repository_impl.dart';
import '../../../../domain/usecases/oncelik/get_first_oncelik.dart';

// REPOSITORY
final oncelikRepositoryProvider = Provider<OncelikRepository>((ref) {
  return OncelikRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllOncelikProvider = Provider(
    (ref) => GetAllUseCase<Oncelik>(ref.watch(oncelikRepositoryProvider)));

final createOncelikProvider = Provider(
    (ref) => CreateUseCase<Oncelik>(ref.watch(oncelikRepositoryProvider)));

final updateOncelikProvider = Provider(
    (ref) => UpdateUseCase<Oncelik>(ref.watch(oncelikRepositoryProvider)));

final deleteOncelikProvider = Provider(
    (ref) => DeleteUseCase<Oncelik>(ref.watch(oncelikRepositoryProvider)));

final getOncelikByIdProvider = Provider(
    (ref) => GetByIdUseCase<Oncelik>(ref.watch(oncelikRepositoryProvider)));

final getFirstOncelikProvider =
    Provider((ref) => GetFirstOncelik(ref.watch(oncelikRepositoryProvider)));
