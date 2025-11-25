// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// ✅ Yeni Soyut Arayüz Importu
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/oncelik.dart';
import '../../domain/repositories/oncelik_repository.dart';
import '../models/oncelik_model.dart';

/// 🧩 Data katmanında gerçek veritabanı erişimini yapan repository implementasyonu.
/// Domain'deki soyut [OncelikRepository]'i uygular.
class OncelikRepositoryImpl implements OncelikRepository {
  // 🔹 Bağımlılık somut sınıftan soyut arayüze çevrildi.
  final AbstractDBService _dbService;

  OncelikRepositoryImpl(this._dbService);

  @override
  Future<Oncelik> getIlkOncelik() async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableOncelik,
      columns: OncelikAlanlar.values,
      orderBy: '${OncelikAlanlar.id} ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return OncelikModel.fromJson(result.first);
    } else {
      throw Exception('Hiç öncelik bulunamadı.');
    }
  }

  @override
  Future<Oncelik> getOncelikById(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableOncelik,
      columns: OncelikAlanlar.values,
      where: '${OncelikAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return OncelikModel.fromJson(maps.first);
    } else {
      throw Exception('Öncelik bulunamadı (ID: $id)');
    }
  }

  @override
  Future<List<Oncelik>> getAllOncelik() async {
    // 👇 DEĞİŞİKLİK: Türü belirttik
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${OncelikAlanlar.kayitZamani} ASC';
    final result = await db.query(tableOncelik, orderBy: orderBy);

    return result.map((json) => OncelikModel.fromJson(json)).toList();
  }

  @override
  Future<Oncelik> createOncelik(Oncelik oncelik) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = OncelikModel.fromEntity(oncelik);
    final id = await db.insert(tableOncelik, model.toJson());

    return model.copyWith(id: id);
  }

  @override
  Future<int> updateOncelik(Oncelik oncelik) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = OncelikModel.fromEntity(oncelik);

    return await db.update(
      tableOncelik,
      model.toJson(),
      where: '${OncelikAlanlar.id} = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<int> deleteOncelik(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return await db.delete(
      tableOncelik,
      where: '${OncelikAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
