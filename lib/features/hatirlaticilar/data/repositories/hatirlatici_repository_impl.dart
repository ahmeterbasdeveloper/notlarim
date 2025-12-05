import '../../../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/hatirlatici.dart';
import '../../domain/repositories/hatirlatici_repository.dart';

// Data
import '../models/hatirlatici_model.dart';
import '../../../../core/base/base_repository_impl.dart';

class HatirlaticiRepositoryImpl extends BaseRepositoryImpl<Hatirlatici>
    implements HatirlaticiRepository {
  HatirlaticiRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableHatirlaticilar,
          (json) => HatirlaticiModel.fromJson(json),
        );

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

  // ✅ Arama implementasyonu eklendi
  @override
  Future<List<Hatirlatici>> searchHatirlaticilar(String query) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where:
          '${HatirlaticiAlanlar.baslik} LIKE ? OR ${HatirlaticiAlanlar.aciklama} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => fromMap(json)).toList();
  }
}
