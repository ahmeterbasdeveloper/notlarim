import 'package:get_it/get_it.dart';
import 'package:notlarim/data/repositories/kullanici_repository_impl.dart';
import 'package:notlarim/domain/repositories/kullanici_repository.dart';
import 'package:notlarim/domain/usecases/kullanici/login_user.dart';

// Abstract Service
import '../abstract_db_service.dart';

// Data Sources
import '../../data/datasources/database_helper.dart';

// -----------------------------------------------------------------------------
// REPOSITORIES (IMPLEMENTATIONS)
// -----------------------------------------------------------------------------
import '../../data/repositories/not_repository_impl.dart';
import '../../data/repositories/kategori_repository_impl.dart';
import '../../data/repositories/oncelik_repository_impl.dart';
import '../../data/repositories/durum_repository_impl.dart';
import '../../data/repositories/gorev_repository_impl.dart';
import '../../data/repositories/hatirlatici_repository_impl.dart';
import '../../data/repositories/kontrol_liste_repository_impl.dart';

// -----------------------------------------------------------------------------
// REPOSITORY INTERFACES
// -----------------------------------------------------------------------------
import '../../domain/repositories/not_repository.dart';
import '../../domain/repositories/kategori_repository.dart';
import '../../domain/repositories/oncelik_repository.dart';
import '../../domain/repositories/durum_repository.dart';
import '../../domain/repositories/gorev_repository.dart';
import '../../domain/repositories/hatirlatici_repository.dart';
import '../../domain/repositories/kontrol_liste_repository.dart';

// -----------------------------------------------------------------------------
// USECASES
// -----------------------------------------------------------------------------

// Notlar
import '../../domain/usecases/not/create_not.dart';
import '../../domain/usecases/not/delete_not.dart';
import '../../domain/usecases/not/get_all_not.dart';
import '../../domain/usecases/not/get_not_by_id.dart';
import '../../domain/usecases/not/get_not_by_kategori.dart';
import '../../domain/usecases/not/get_not_by_oncelik.dart';
import '../../domain/usecases/not/get_not_by_durum.dart';
import '../../domain/usecases/not/search_not.dart';
import '../../domain/usecases/not/update_not.dart';

// Kategoriler
import '../../domain/usecases/kategori/get_all_kategori.dart';
import '../../domain/usecases/kategori/get_kategori_by_id.dart';
import '../../domain/usecases/kategori/create_kategori.dart';
import '../../domain/usecases/kategori/update_kategori.dart';
import '../../domain/usecases/kategori/delete_kategori.dart';
import '../../domain/usecases/kategori/get_first_kategori.dart'; // Yeni eklenen

// Öncelikler
import '../../domain/usecases/oncelik/get_all_oncelik.dart';
import '../../domain/usecases/oncelik/get_oncelik_by_id.dart';
import '../../domain/usecases/oncelik/create_oncelik.dart';
import '../../domain/usecases/oncelik/update_oncelik.dart';
import '../../domain/usecases/oncelik/delete_oncelik.dart';
import '../../domain/usecases/oncelik/get_first_oncelik.dart'; // Yeni eklenen

// Durumlar
import '../../domain/usecases/durum/get_all_durum.dart';
import '../../domain/usecases/durum/get_durum_by_id.dart';
import '../../domain/usecases/durum/create_durum.dart';
import '../../domain/usecases/durum/update_durum.dart';
import '../../domain/usecases/durum/delete_durum.dart';

// Görevler
import '../../domain/usecases/gorev/get_all_gorev.dart';
import '../../domain/usecases/gorev/get_gorev_by_id.dart';
import '../../domain/usecases/gorev/create_gorev.dart';
import '../../domain/usecases/gorev/update_gorev.dart';
import '../../domain/usecases/gorev/delete_gorev.dart';

// Hatırlatıcılar
import '../../domain/usecases/hatirlatici/get_all_hatirlatici.dart';
import '../../domain/usecases/hatirlatici/get_hatirlatici_by_id.dart';
import '../../domain/usecases/hatirlatici/create_hatirlatici.dart';
import '../../domain/usecases/hatirlatici/update_hatirlatici.dart';
import '../../domain/usecases/hatirlatici/delete_hatirlatici.dart';
import '../../domain/usecases/hatirlatici/get_hatirlatici_by_durum.dart';

// Kontrol Listeleri
import '../../domain/usecases/kontrol_liste/get_all_kontrol_liste.dart';
import '../../domain/usecases/kontrol_liste/get_kontrol_liste_by_id.dart';
import '../../domain/usecases/kontrol_liste/create_kontrol_liste.dart';
import '../../domain/usecases/kontrol_liste/update_kontrol_liste.dart';
import '../../domain/usecases/kontrol_liste/delete_kontrol_liste.dart';
import '../../domain/usecases/kontrol_liste/GetKontrolListeByDurum.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Core
  // Database Service (Singleton)
  sl.registerLazySingleton<AbstractDBService>(() => DatabaseHelper.instance);

  // ===========================================================================
  // 1. NOTLAR (Notes)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<NotRepository>(() => NotRepositoryImpl(
        sl(), // AbstractDBService
        kategoriRepository: sl(),
        oncelikRepository: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => CreateNot(sl()));
  sl.registerLazySingleton(() => DeleteNot(sl()));
  sl.registerLazySingleton(() => GetAllNot(sl()));
  sl.registerLazySingleton(() => GetNotById(sl()));
  sl.registerLazySingleton(() => GetNotByKategori(sl()));
  sl.registerLazySingleton(() => GetNotByOncelik(sl()));
  sl.registerLazySingleton(() => GetNotByDurum(sl()));
  sl.registerLazySingleton(() => SearchNot(sl()));
  sl.registerLazySingleton(() => UpdateNot(sl()));

  // ===========================================================================
  // 2. KATEGORİLER (Categories)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<KategoriRepository>(
      () => KategoriRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllKategori(sl()));
  sl.registerLazySingleton(() => GetKategoriById(sl()));
  sl.registerLazySingleton(() => CreateKategori(sl()));
  sl.registerLazySingleton(() => UpdateKategori(sl()));
  sl.registerLazySingleton(() => DeleteKategori(sl()));
  sl.registerLazySingleton(() => GetFirstKategori(sl()));

  // ===========================================================================
  // 3. ÖNCELİKLER (Priorities)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<OncelikRepository>(
      () => OncelikRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllOncelik(sl()));
  sl.registerLazySingleton(() => GetOncelikById(sl()));
  sl.registerLazySingleton(() => CreateOncelik(sl()));
  sl.registerLazySingleton(() => UpdateOncelik(sl()));
  sl.registerLazySingleton(() => DeleteOncelik(sl()));
  sl.registerLazySingleton(() => GetFirstOncelik(sl()));

  // ===========================================================================
  // 4. DURUMLAR (Statuses)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<DurumRepository>(() => DurumRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllDurum(sl()));
  sl.registerLazySingleton(() => GetDurumById(sl()));
  sl.registerLazySingleton(() => CreateDurum(sl()));
  sl.registerLazySingleton(() => UpdateDurum(sl()));
  sl.registerLazySingleton(() => DeleteDurum(sl()));

  // ===========================================================================
  // 5. GÖREVLER (Tasks)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<GorevRepository>(() => GorevRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllGorev(sl()));
  sl.registerLazySingleton(() => GetGorevById(sl()));
  sl.registerLazySingleton(() => CreateGorev(sl()));
  sl.registerLazySingleton(() => UpdateGorev(sl()));
  sl.registerLazySingleton(() => DeleteGorev(sl()));

  // ===========================================================================
  // 6. HATIRLATICILAR (Reminders)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<HatirlaticiRepository>(
      () => HatirlaticiRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllHatirlatici(sl()));
  sl.registerLazySingleton(() => GetHatirlaticiById(sl()));
  sl.registerLazySingleton(() => CreateHatirlatici(sl()));
  sl.registerLazySingleton(() => UpdateHatirlatici(sl()));
  sl.registerLazySingleton(() => DeleteHatirlatici(sl()));
  sl.registerLazySingleton(() => GetHatirlaticiByDurum(sl()));

  // ===========================================================================
  // 7. KONTROL LİSTESİ (Checklists)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<KontrolListeRepository>(
      () => KontrolListeRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetAllKontrolListe(sl()));
  sl.registerLazySingleton(() => GetKontrolListeById(sl()));
  sl.registerLazySingleton(() => CreateKontrolListe(sl()));
  sl.registerLazySingleton(() => UpdateKontrolListe(sl()));
  sl.registerLazySingleton(() => DeleteKontrolListe(sl()));
  sl.registerLazySingleton(() => GetKontrolListeByDurum(sl()));

  // ===========================================================================
  // 8. KULLANICI (User / Auth)
  // ===========================================================================
  // Repository
  sl.registerLazySingleton<KullaniciRepository>(
      () => KullaniciRepositoryImpl(sl())); // sl() -> AbstractDBService

  // UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
}
