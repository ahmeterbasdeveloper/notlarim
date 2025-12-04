import 'package:notlarim/core/base/crud_repository.dart';
import 'package:sqflite/sqflite.dart';
import '../abstract_db_service.dart';
import 'base_entity.dart';

class BaseRepositoryImpl<T extends BaseEntity> implements CrudRepository<T> {
  final AbstractDBService _dbService;
  final String tableName;

  // 🛠️ Veritabanından gelen veriyi nesneye çeviren fonksiyon
  final T Function(Map<String, dynamic>) fromMap;

  BaseRepositoryImpl(this._dbService, this.tableName, this.fromMap);

  Future<Database> get db async => await _dbService.getDatabaseInstance();

  @override
  Future<List<T>> getAll() async {
    final database = await db;
    final result = await database.query(tableName);

    return result.map((e) => fromMap(e)).toList();
  }

  @override
  Future<T?> getById(int id) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '_id = ?', // ID kolon adınız '_id' ise
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> create(T entity) async {
    final database = await db;
    // Entity içindeki toMap() burada devreye girer
    return await database.insert(tableName, entity.toMap());
  }

  @override
  Future<int> update(T entity) async {
    final database = await db;
    return await database.update(
      tableName,
      entity.toMap(),
      where: '_id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: '_id = ?',
      whereArgs: [id],
    );
  }
}
