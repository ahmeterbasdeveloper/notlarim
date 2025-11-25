// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/hatirlatici.dart';
import '../../domain/repositories/hatirlatici_repository.dart';
import '../models/hatirlatici_model.dart';

class HatirlaticiRepositoryImpl implements HatirlaticiRepository {
  final AbstractDBService _dbService;

  HatirlaticiRepositoryImpl(this._dbService);

  @override
  Future<List<Hatirlatici>> getAllHatirlatici() async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${HatirlaticiAlanlar.kayitZamani} ASC';

    // Artık Dart, bunun bir Map Listesi olduğunu anlıyor
    final result = await db.query(tableHatirlaticilar, orderBy: orderBy);

    return result.map((json) => HatirlaticiModel.fromJson(json)).toList();
  }

  @override
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableHatirlaticilar,
      where: '${HatirlaticiAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );

    return result.map((json) => HatirlaticiModel.fromJson(json)).toList();
  }

  @override
  Future<Hatirlatici> createHatirlatici(Hatirlatici hatirlatici) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Entity → Model
    final model = HatirlaticiModel(
      baslik: hatirlatici.baslik,
      aciklama: hatirlatici.aciklama,
      kategoriId: hatirlatici.kategoriId,
      oncelikId: hatirlatici.oncelikId,
      hatirlatmaTarihiZamani: hatirlatici.hatirlatmaTarihiZamani,
      kayitZamani: hatirlatici.kayitZamani,
      durumId: hatirlatici.durumId,
    );

    final id = await db.insert(tableHatirlaticilar, model.toJson());
    return hatirlatici.copyWith(id: id);
  }

  @override
  Future<int> updateHatirlatici(Hatirlatici hatirlatici) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = HatirlaticiModel(
      id: hatirlatici.id,
      baslik: hatirlatici.baslik,
      aciklama: hatirlatici.aciklama,
      kategoriId: hatirlatici.kategoriId,
      oncelikId: hatirlatici.oncelikId,
      hatirlatmaTarihiZamani: hatirlatici.hatirlatmaTarihiZamani,
      kayitZamani: hatirlatici.kayitZamani,
      durumId: hatirlatici.durumId,
    );

    return db.update(
      tableHatirlaticilar,
      model.toJson(),
      where: '${HatirlaticiAlanlar.id} = ?',
      whereArgs: [hatirlatici.id],
    );
  }

  @override
  Future<int> deleteHatirlatici(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return db.delete(
      tableHatirlaticilar,
      where: '${HatirlaticiAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
