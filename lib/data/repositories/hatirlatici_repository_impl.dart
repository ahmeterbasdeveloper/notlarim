import '../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/hatirlatici.dart';
import '../../domain/repositories/hatirlatici_repository.dart';

// Data
import '../models/hatirlatici_model.dart';
import 'base_repository_impl.dart'; // ✅ Base Impl

class HatirlaticiRepositoryImpl extends BaseRepositoryImpl<Hatirlatici>
    implements HatirlaticiRepository {
  HatirlaticiRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableHatirlaticilar, // Model dosyasındaki tablo adı
          (json) => HatirlaticiModel.fromJson(json), // Dönüştürücü
        );

  // ❌ create, update, delete, getAll metodlarını SİLİN.

  // 👇 SADECE ÖZEL METODLAR:
  @override
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${HatirlaticiAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );
    return result.map((json) => fromMap(json)).toList();
  }
}
