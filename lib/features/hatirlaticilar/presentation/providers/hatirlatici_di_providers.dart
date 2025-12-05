import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/core_providers.dart';
import '../../../../../../core/usecases/crud_usecases.dart';

import '../../domain/entities/hatirlatici.dart';
import '../../domain/repositories/hatirlatici_repository.dart';
import '../../data/repositories/hatirlatici_repository_impl.dart';
import '../../domain/usecases/get_hatirlatici_by_durum.dart';

// ✅ Yeni UseCase import edildi
import '../../domain/usecases/search_hatirlatici.dart';

// REPOSITORY
final hatirlaticiRepositoryProvider = Provider<HatirlaticiRepository>((ref) {
  return HatirlaticiRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllHatirlaticiProvider = Provider((ref) =>
    GetAllUseCase<Hatirlatici>(ref.watch(hatirlaticiRepositoryProvider)));

final createHatirlaticiProvider = Provider((ref) =>
    CreateUseCase<Hatirlatici>(ref.watch(hatirlaticiRepositoryProvider)));

final updateHatirlaticiProvider = Provider((ref) =>
    UpdateUseCase<Hatirlatici>(ref.watch(hatirlaticiRepositoryProvider)));

final deleteHatirlaticiProvider = Provider((ref) =>
    DeleteUseCase<Hatirlatici>(ref.watch(hatirlaticiRepositoryProvider)));

final getHatirlaticiByIdProvider = Provider((ref) =>
    GetByIdUseCase<Hatirlatici>(ref.watch(hatirlaticiRepositoryProvider)));

final getHatirlaticiByDurumProvider = Provider(
    (ref) => GetHatirlaticiByDurum(ref.watch(hatirlaticiRepositoryProvider)));

// ✅ Arama Provider'ı eklendi
final searchHatirlaticiProvider = Provider(
    (ref) => SearchHatirlatici(ref.watch(hatirlaticiRepositoryProvider)));
