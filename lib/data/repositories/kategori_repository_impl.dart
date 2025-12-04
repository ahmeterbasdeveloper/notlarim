// Sqflite

// Abstract Service
import '../../../core/abstract_db_service.dart';

// Domain & Entities
import '../../domain/entities/kategori.dart';
import '../../domain/repositories/kategori_repository.dart';

// Model & Generic Base
import '../models/kategori_model.dart'; // tableKategoriler ve KategoriModel buradan gelir
import 'base_repository_impl.dart';

/// 🧩 Kategori Repository Implementation
class KategoriRepositoryImpl extends BaseRepositoryImpl<Kategori>
    implements KategoriRepository {
  KategoriRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableKategoriler, // 1. Model dosyasındaki tablo adı sabiti
          (json) => KategoriModel.fromJson(json), // 2. Dönüştürücü fonksiyon
        );

  // ---------------------------------------------------------------------------
  // 🌟 ÖZEL METODLAR
  // create, update, delete, getAll metodlarını BURAYA YAZMIYORUZ.
  // Onlar BaseRepositoryImpl'den miras alındı.
  // ---------------------------------------------------------------------------

  @override
  Future<Kategori> getIlkKategori() async {
    // 'db' getter'ı BaseRepositoryImpl'den gelir
    final database = await db;

    final result = await database.query(
      tableName, // super'dan gelen tablo adı
      orderBy:
          '${KategoriAlanlar.id} ASC', // Model'deki sabitleri kullanabilirsiniz
      limit: 1,
    );

    if (result.isNotEmpty) {
      // 'fromMap' fonksiyonu üst sınıftan gelir
      return fromMap(result.first);
    } else {
      throw Exception('Hiç kategori bulunamadı.');
    }
  }
}
