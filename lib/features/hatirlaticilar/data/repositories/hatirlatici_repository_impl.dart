import '../../../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/hatirlatici.dart';
import '../../domain/repositories/hatirlatici_repository.dart';

// Data
import '../models/hatirlatici_model.dart';
import '../../../../core/base/base_repository_impl.dart'; // ✅ Base Impl

class HatirlaticiRepositoryImpl extends BaseRepositoryImpl<Hatirlatici>
    implements HatirlaticiRepository {
  HatirlaticiRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableHatirlaticilar, // Model dosyasındaki tablo adı
          (json) => HatirlaticiModel.fromJson(json), // Dönüştürücü
        );

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

  // ---------------------------------------------------------------------------
  // 💡 HATIRLATICI İLE İLGİLİ METODLAR
  // ---------------------------------------------------------------------------
  Future<Hatirlatici> getHatirlaticiId(int id) async {
    // ✅ DOĞRU SATIR:
    final database =
        await db; // BaseRepositoryImpl'den gelen veritabanı nesnesi

    final maps = await database.query(
      tableHatirlaticilar, // tableName değişkenini de kullanabilirsiniz
      columns: HatirlaticiAlanlar.values,
      where: '${HatirlaticiAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final model = HatirlaticiModel.fromJson(maps.first);
      return model.toEntity();
    } else {
      throw Exception('Hatırlatıcı bulunamadı (ID: $id)');
    }
  }
}
