// lib/data/repositories/not_repository_impl.dart

import '../../../../../core/abstract_db_service.dart';

// Entities & Models
import '../../domain/entities/not.dart';
import '../models/not_model.dart';

// Repositories
import '../../domain/repositories/not_repository.dart';
import '../../../kategori/domain/repositories/kategori_repository.dart';
import '../../../oncelik/domain/repositories/oncelik_repository.dart';

// ✅ Base Impl Importu (Standart işler buradan gelecek)
import '../../../../core/base/base_repository_impl.dart';

class NotRepositoryImpl extends BaseRepositoryImpl<Not>
    implements NotRepository {
  final KategoriRepository kategoriRepository;
  final OncelikRepository oncelikRepository;

  NotRepositoryImpl(
    AbstractDBService dbService, {
    required this.kategoriRepository,
    required this.oncelikRepository,
  }) : super(
          dbService,
          tableNotlar, // Model dosyasındaki tablo adı sabiti
          (json) => NotModel.fromJson(json), // Model dönüştürücü
        );

  // ---------------------------------------------------------------------------
  // ❌ SİLİNEN METODLAR:
  // createNot, updateNot, deleteNot, getAllNotlar, getNotById
  // Bunları sildik çünkü BaseRepositoryImpl bunları otomatik yapıyor.
  // ---------------------------------------------------------------------------

  // 👇 SADECE ÖZEL SORGULARI BURAYA YAZIYORUZ:

  @override
  Future<List<Not>> searchNotlar(String searchText) async {
    final database = await db; // 'db' getter'ı Base'den gelir
    final result = await database.query(
      tableName, // 'tableName' Base'den gelir
      where: '${NotAlanlar.baslik} LIKE ?',
      whereArgs: ['%$searchText%'],
    );
    // 'fromMap' Base'den gelir
    return result.map((json) => fromMap(json)).toList();
  }

  @override
  Future<List<Not>> getNotlarByDurum(int durumId) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${NotAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );
    return result.map((json) => fromMap(json)).toList();
  }

  @override
  Future<List<Not>> getNotlarByKategori(int kategoriId) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${NotAlanlar.kategoriId} = ?',
      whereArgs: [kategoriId],
    );
    return result.map((json) => fromMap(json)).toList();
  }

  @override
  Future<List<Not>> getNotlarByOncelik(int oncelikId) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${NotAlanlar.oncelikId} = ?',
      whereArgs: [oncelikId],
    );
    return result.map((json) => fromMap(json)).toList();
  }

  // Ekstra: İlişkili verileri getirme (Opsiyonel)
  Future<List<Map<String, dynamic>>> getAllNotWithDetails() async {
    final notlar = await getAll(); // Base'den gelen getAll()
    final List<Map<String, dynamic>> notlarWithDetails = [];

    for (final not in notlar) {
      // Generic Repository metodu: getById
      final kategori = await kategoriRepository.getById(not.kategoriId);
      final oncelik = await oncelikRepository.getById(not.oncelikId);

      notlarWithDetails.add({
        'not': not,
        'kategori': kategori,
        'oncelik': oncelik,
      });
    }

    return notlarWithDetails;
  }
}
