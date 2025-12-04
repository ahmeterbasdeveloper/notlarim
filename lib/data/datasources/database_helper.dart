// lib/data/datasources/database_helper.dart

import 'package:flutter/foundation.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../../core/abstract_db_service.dart';

// ✅ YENİ: Parçalanmış mantık dosyaları import edildi
import '../../core/database/db_schema.dart';
import '../../core/database/db_defaults.dart';

// Modeller (Sadece getHatirlaticiId fonksiyonu için gerekli)
import '../models/hatirlatici_model.dart';

/// DatabaseHelper sınıfı AbstractDBService arayüzünü uygular.
class DatabaseHelper implements AbstractDBService {
  static int pathDbDirectoryTip = 2;
  static const _databaseName = "notlar.db";
  static const _databaseVersion = 2;

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ---------------------------------------------------------------------------
  // 💡 ABSTRACTDBSERVICE IMPLEMENTASYONU
  // ---------------------------------------------------------------------------

  @override
  Future<dynamic> getDatabaseInstance() async {
    return await database;
  }

  @override
  Future<String> getDatabasePath(String dbName) async {
    String path;
    if (pathDbDirectoryTip == 1) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, dbName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }
    return path;
  }

  @override
  Future<void> closeDatabase() async {
    await close();
  }

  // ---------------------------------------------------------------------------
  // 💾 CORE SORGULAMA VE YÖNETİM METOTLARI
  // ---------------------------------------------------------------------------

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = await getDatabasePath(filePath);

    if (kDebugMode) print('📦 Veritabanı açılıyor: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  static Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 🔄 Versiyon yükseltme işlemi
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print("♻️ Veritabanı güncelleniyor: v$oldVersion -> v$newVersion");
    }

    // ✅ DbSchema üzerinden silme işlemi
    await DbSchema.dropTables(db);

    // ✅ Yeniden oluşturma
    await _onCreate(db, newVersion);
  }

  /// 🧱 Veritabanı oluşturulduğunda çalışır
  static Future<void> _onCreate(Database db, int version) async {
    // 1. Tabloları oluştur (DbSchema kullanılarak)
    await DbSchema.createTables(db);

    // 2. Varsayılan verileri ekle (DbDefaults kullanılarak)
    await DbDefaults.insertDefaultData(db);
  }

  /// 🔒 Bağlantıyı kapatır
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      if (kDebugMode) {
        print('🧱 DatabaseHelper: Veritabanı bağlantısı kapatıldı');
      }
    }
  }

  /// 🔁 Bağlantıyı yeniden açar (yedekten sonra kullanılır)
  Future<void> reopen() async {
    await close();
    _database = await _initDB(_databaseName);
    if (kDebugMode) {
      print('🔄 DatabaseHelper: Veritabanı bağlantısı yeniden açıldı');
    }
  }

  // ---------------------------------------------------------------------------
  // 💡 HATIRLATICI İLE İLGİLİ METODLAR
  // ---------------------------------------------------------------------------
  Future<Hatirlatici> getHatirlaticiId(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableHatirlaticilar,
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
