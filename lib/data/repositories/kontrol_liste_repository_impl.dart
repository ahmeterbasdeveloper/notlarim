// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/kontrol_liste.dart';
import '../../domain/repositories/kontrol_liste_repository.dart';
import '../models/kontrol_liste_model.dart';

class KontrolListeRepositoryImpl implements KontrolListeRepository {
  // 🔹 Bağımlılık somut sınıftan soyut arayüze çevrildi.
  final AbstractDBService _dbService;

  KontrolListeRepositoryImpl(this._dbService);

  @override
  Future<KontrolListe> getById(int id) async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableKontrolListe,
      columns: KontrolListeAlanlar.values,
      where: '${KontrolListeAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return KontrolListeModel.fromJson(maps.first).toEntity();
    } else {
      throw Exception('ID $id not found');
    }
  }

  @override
  Future<List<KontrolListe>> getAll() async {
    // 👇 DEĞİŞİKLİK: Türü belirttik
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${KontrolListeAlanlar.kayitZamani} ASC';

    final result = await db.query(tableKontrolListe, orderBy: orderBy);

    return result
        .map((json) => KontrolListeModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<KontrolListe>> getByDurum(int durumId) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableKontrolListe,
      where: '${KontrolListeAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );

    return result
        .map((json) => KontrolListeModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<KontrolListe> create(KontrolListe kontrolListe) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = KontrolListeModel.fromEntity(kontrolListe);

    final id = await db.insert(tableKontrolListe, model.toJson());
    // model.copyWith metodu KontrolListeModel içinde var
    return model.copyWith(id: id).toEntity();
  }

  @override
  Future<int> update(KontrolListe kontrolListe) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = KontrolListeModel.fromEntity(kontrolListe);

    return db.update(
      tableKontrolListe,
      model.toJson(),
      where: '${KontrolListeAlanlar.id} = ?',
      whereArgs: [kontrolListe.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return db.delete(
      tableKontrolListe,
      where: '${KontrolListeAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
