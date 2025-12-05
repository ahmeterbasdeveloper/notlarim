import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/core_providers.dart';
import '../../../../../../core/usecases/crud_usecases.dart';

// ✅ Yeni UseCase import
import '../../domain/usecases/search_gorev.dart';

import '../../domain/entities/gorev.dart';
import '../../domain/repositories/gorev_repository.dart';
import '../../data/repositories/gorev_repository_impl.dart';

// REPOSITORY
final gorevRepositoryProvider = Provider<GorevRepository>((ref) {
  return GorevRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllGorevProvider =
    Provider((ref) => GetAllUseCase<Gorev>(ref.watch(gorevRepositoryProvider)));

final createGorevProvider =
    Provider((ref) => CreateUseCase<Gorev>(ref.watch(gorevRepositoryProvider)));

final updateGorevProvider =
    Provider((ref) => UpdateUseCase<Gorev>(ref.watch(gorevRepositoryProvider)));

final deleteGorevProvider =
    Provider((ref) => DeleteUseCase<Gorev>(ref.watch(gorevRepositoryProvider)));

final getGorevByIdProvider = Provider(
    (ref) => GetByIdUseCase<Gorev>(ref.watch(gorevRepositoryProvider)));

// ✅ Arama Provider'ı
final searchGorevProvider =
    Provider((ref) => SearchGorev(ref.watch(gorevRepositoryProvider)));
