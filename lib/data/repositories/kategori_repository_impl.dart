// ✅ Sqflite importunu ekledik
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../../../core/abstract_db_service.dart';

import '../../domain/entities/kategori.dart';
import '../../domain/repositories/kategori_repository.dart';
import '../models/kategori_model.dart';

/// 🧩 Data katmanında gerçek veritabanı erişimini yapan repository implementasyonu.
/// Domain'deki soyut [KategoriRepository]'i uygular.
class KategoriRepositoryImpl implements KategoriRepository {
  // 🔹 Bağımlılık somut sınıftan soyut arayüze çevrildi.
  final AbstractDBService _dbService;

  KategoriRepositoryImpl(this._dbService);

  @override
  Future<Kategori> getIlkKategori() async {
    // 👇 DEĞİŞİKLİK: 'final db' yerine 'final Database db' yazdık
    final Database db = await _dbService.getDatabaseInstance();

    final result = await db.query(
      tableKategoriler,
      columns: KategoriAlanlar.values,
      orderBy: '${KategoriAlanlar.id} ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return KategoriModel.fromJson(result.first);
    } else {
      throw Exception('Hiç kategori bulunamadı.');
    }
  }

  @override
  Future<Kategori> getKategoriById(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    final maps = await db.query(
      tableKategoriler,
      columns: KategoriAlanlar.values,
      where: '${KategoriAlanlar.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return KategoriModel.fromJson(maps.first);
    } else {
      throw Exception('Kategori bulunamadı (ID: $id)');
    }
  }

  @override
  Future<List<Kategori>> getAllKategori() async {
    final Database db = await _dbService.getDatabaseInstance();

    const orderBy = '${KategoriAlanlar.kayitZamani} ASC';
    final result = await db.query(tableKategoriler, orderBy: orderBy);

    // Her kayıt JSON’dan modele çevrilir
    return result.map((json) => KategoriModel.fromJson(json)).toList();
  }

  @override
  Future<Kategori> createKategori(Kategori kategori) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Entity -> Model dönüşümü
    final model = KategoriModel.fromEntity(kategori);

    // Yeni kayıt ekleniyor
    final id = await db.insert(tableKategoriler, model.toJson());

    // Yeni ID ile geri dön
    return model.copyWith(id: id);
  }

  @override
  Future<int> updateKategori(Kategori kategori) async {
    final Database db = await _dbService.getDatabaseInstance();

    final model = KategoriModel.fromEntity(kategori);

    return await db.update(
      tableKategoriler,
      model.toJson(),
      where: '${KategoriAlanlar.id} = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<int> deleteKategori(int id) async {
    final Database db = await _dbService.getDatabaseInstance();

    return await db.delete(
      tableKategoriler,
      where: '${KategoriAlanlar.id} = ?',
      whereArgs: [id],
    );
  }
}
