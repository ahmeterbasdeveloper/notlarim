// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/durum.dart';
import '../../domain/repositories/durum_repository.dart';
import '../models/durum_model.dart';

/// Data katmanında gerçek veritabanı erişimini yapan repository.
class DurumRepositoryImpl implements DurumRepository {
  final AbstractDBService _dbService;

  DurumRepositoryImpl(this._dbService);

  @override
  Future<Durum> getDurumById(int id) async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableDurumlar,
      columns: DurumAlanlar.values,
      where: '${DurumAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DurumModel.fromJson(maps.first);
    } else {
      throw Exception('Durum bulunamadı (ID: $id)');
    }
  }

  @override
  Future<List<Durum>> getAllDurum() async {
    // 👇 DEĞİŞİKLİK: Türü belirttik
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${DurumAlanlar.kayitZamani} ASC';
    final result = await db.query(tableDurumlar, orderBy: orderBy);

    // Her kayıt JSON’dan modele çevrilir
    return result.map((json) => DurumModel.fromJson(json)).toList();
  }

  @override
  Future<Durum> createDurum(Durum durum) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Entity -> Model dönüşümü
    final model = DurumModel.fromEntity(durum);

    // Yeni kayıt ekleniyor
    final id = await db.insert(tableDurumlar, model.toJson());

    // Yeni ID ile geri dön
    return model.copyWith(id: id);
  }

  @override
  Future<int> updateDurum(Durum durum) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = DurumModel.fromEntity(durum);

    return await db.update(
      tableDurumlar,
      model.toJson(),
      where: '${DurumAlanlar.id} = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<int> deleteDurum(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return await db.delete(
      tableDurumlar,
      where: '${DurumAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
