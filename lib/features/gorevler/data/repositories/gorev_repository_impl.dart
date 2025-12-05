import '../../../../../core/abstract_db_service.dart';

// Domain & Models
import '../../domain/entities/gorev.dart';
import '../../domain/repositories/gorev_repository.dart';
import '../models/gorev_model.dart';

// Base
import '../../../../core/base/base_repository_impl.dart';

class GorevRepositoryImpl extends BaseRepositoryImpl<Gorev>
    implements GorevRepository {
  GorevRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableGorevler,
          (json) => GorevModel.fromJson(json),
        );

  // ✅ Arama Implementasyonu
  @override
  Future<List<Gorev>> searchGorevler(String query) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${GorevAlanlar.baslik} LIKE ? OR ${GorevAlanlar.aciklama} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => fromMap(json)).toList();
  }
}
