import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/core_providers.dart';
import '../../../../../../core/usecases/crud_usecases.dart';

import '../../domain/entities/kontrol_liste.dart';
import '../../domain/repositories/kontrol_liste_repository.dart';
import '../../data/repositories/kontrol_liste_repository_impl.dart';
import '../../domain/usecases/get_kontrol_liste_by_durum.dart';

// REPOSITORY
final kontrolListeRepositoryProvider = Provider<KontrolListeRepository>((ref) {
  return KontrolListeRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final getAllKontrolListeProvider = Provider((ref) =>
    GetAllUseCase<KontrolListe>(ref.watch(kontrolListeRepositoryProvider)));

final createKontrolListeProvider = Provider((ref) =>
    CreateUseCase<KontrolListe>(ref.watch(kontrolListeRepositoryProvider)));

final updateKontrolListeProvider = Provider((ref) =>
    UpdateUseCase<KontrolListe>(ref.watch(kontrolListeRepositoryProvider)));

final deleteKontrolListeGenericProvider = Provider((ref) =>
    DeleteUseCase<KontrolListe>(ref.watch(kontrolListeRepositoryProvider)));

final getKontrolListeByIdProvider = Provider((ref) =>
    GetByIdUseCase<KontrolListe>(ref.watch(kontrolListeRepositoryProvider)));

final getKontrolListeByDurumProvider = Provider(
    (ref) => GetKontrolListeByDurum(ref.watch(kontrolListeRepositoryProvider)));
