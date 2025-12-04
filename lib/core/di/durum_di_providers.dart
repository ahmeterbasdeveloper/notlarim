import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/usecases/crud_usecases.dart';

import '../../../../domain/entities/durum.dart';
import '../../../../domain/repositories/durum_repository.dart';
import '../../../../data/repositories/durum_repository_impl.dart';

// REPOSITORY
final durumRepositoryProvider = Provider<DurumRepository>((ref) {
  return DurumRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllDurumProvider =
    Provider((ref) => GetAllUseCase<Durum>(ref.watch(durumRepositoryProvider)));

final createDurumProvider =
    Provider((ref) => CreateUseCase<Durum>(ref.watch(durumRepositoryProvider)));

final updateDurumProvider =
    Provider((ref) => UpdateUseCase<Durum>(ref.watch(durumRepositoryProvider)));

final deleteDurumProvider =
    Provider((ref) => DeleteUseCase<Durum>(ref.watch(durumRepositoryProvider)));

final getDurumByIdProvider = Provider(
    (ref) => GetByIdUseCase<Durum>(ref.watch(durumRepositoryProvider)));
