// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// ✅ Yeni Soyut Arayüz Importu
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/gorev.dart';
import '../../domain/repositories/gorev_repository.dart';
import '../models/gorev_model.dart';

/// 🧩 Data katmanında gerçek veritabanı erişimini yapan repository implementasyonu.
/// Domain'deki soyut [GorevRepository]'i uygular.
class GorevRepositoryImpl implements GorevRepository {
  // 🔹 Bağımlılık somut sınıftan soyut arayüze çevrildi.
  final AbstractDBService _dbService;

  GorevRepositoryImpl(this._dbService);

  @override
  Future<Gorev> getGorevById(int id) async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableGorevler,
      columns: GorevAlanlar.values,
      where: '${GorevAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GorevModel.fromJson(maps.first);
    } else {
      throw Exception('Görev bulunamadı (ID: $id)');
    }
  }

  @override
  Future<List<Gorev>> getAllGorev() async {
    // 👇 DEĞİŞİKLİK: Türü belirttik
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${GorevAlanlar.kayitZamani} ASC';
    final result = await db.query(tableGorevler, orderBy: orderBy);

    // Her kayıt JSON’dan modele çevrilir
    return result.map((json) => GorevModel.fromJson(json)).toList();
  }

  @override
  Future<Gorev> createGorev(Gorev gorev) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Entity -> Model dönüşümü
    final model = GorevModel.fromEntity(gorev);

    // Yeni kayıt ekleniyor
    final id = await db.insert(tableGorevler, model.toJson());

    // Yeni ID ile geri dön
    return model.copyWith(id: id);
  }

  @override
  Future<int> updateGorev(Gorev gorev) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = GorevModel.fromEntity(gorev);

    return await db.update(
      tableGorevler,
      model.toJson(),
      where: '${GorevAlanlar.id} = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<int> deleteGorev(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return await db.delete(
      tableGorevler,
      where: '${GorevAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
