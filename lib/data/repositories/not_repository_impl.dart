import 'package:sqflite/sqflite.dart'; // 👈 1. BU SATIRI EKLE

import '../../domain/entities/not.dart';
import '../../domain/repositories/not_repository.dart';
import '../../domain/repositories/kategori_repository.dart';
import '../../domain/repositories/oncelik_repository.dart';
import '../models/not_model.dart';

// Abstract Interface
import '../../../core/abstract_db_service.dart';

class NotRepositoryImpl implements NotRepository {
  final AbstractDBService _dbService;

  final KategoriRepository kategoriRepository;
  final OncelikRepository oncelikRepository;

  NotRepositoryImpl(
    this._dbService, {
    required this.kategoriRepository,
    required this.oncelikRepository,
  });

  @override
  Future<Not?> getNotById(int id) async {
    // 👇 2. DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazıyoruz
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableNotlar,
      columns: NotAlanlar.values,
      where: '${NotAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NotModel.fromJson(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<List<Not>> getAllNotlar() async {
    // 👇 BURASI KRİTİK: Türü 'Database' olarak belirttik
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${NotAlanlar.kayitZamani} DESC';

    // Artık Dart, result'ın List<Map> olduğunu biliyor
    final result = await db.query(tableNotlar, orderBy: orderBy);

    return result.map((json) => NotModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<Not>> searchNotlar(String searchText) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableNotlar,
      where: '${NotAlanlar.baslik} LIKE ?',
      whereArgs: ['%$searchText%'],
    );

    return result.map((json) => NotModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<Not>> getNotlarByDurum(int durumId) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableNotlar,
      where: '${NotAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );

    return result.map((json) => NotModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<Not>> getNotlarByKategori(int kategoriId) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableNotlar,
      where: '${NotAlanlar.kategoriId} = ?',
      whereArgs: [kategoriId],
    );

    return result.map((json) => NotModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<Not>> getNotlarByOncelik(int oncelikId) async {
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableNotlar,
      where: '${NotAlanlar.oncelikId} = ?',
      whereArgs: [oncelikId],
    );

    return result.map((json) => NotModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<Not> createNot(Not not) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = NotModel.fromEntity(not);
    final id = await db.insert(tableNotlar, model.toJson());

    return not.copyWith(id: id);
  }

  @override
  Future<int> updateNot(Not not) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = NotModel.fromEntity(not);

    return await db.update(
      tableNotlar,
      model.toJson(),
      where: '${NotAlanlar.id} = ?',
      whereArgs: [not.id],
    );
  }

  @override
  Future<int> deleteNot(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return await db.delete(
      tableNotlar,
      where: '${NotAlanlar.id} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotWithDetails() async {
    final notlar = await getAllNotlar();
    final List<Map<String, dynamic>> notlarWithDetails = [];

    for (final not in notlar) {
      final kategori = await kategoriRepository.getKategoriById(not.kategoriId);
      final oncelik = await oncelikRepository.getOncelikById(not.oncelikId);

      notlarWithDetails.add({
        'not': not,
        'kategori': kategori,
        'oncelik': oncelik,
      });
    }

    return notlarWithDetails;
  }
}
