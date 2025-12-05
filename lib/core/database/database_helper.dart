// lib/core/database/database_helper.dart

import 'dart:io'; // Dosya işlemleri için gerekli
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Abstract Interface
import '../abstract_db_service.dart';

// ✅ Parçalanmış mantık dosyaları
import 'db_schema.dart';
import 'db_defaults.dart';

/// DatabaseHelper sınıfı AbstractDBService arayüzünü uygular.
class DatabaseHelper implements AbstractDBService {
  static int pathDbDirectoryTip = 2;
  static const _databaseName = "notlar.db";

  // ⚙️ AYAR: Bu değeri 0 (sıfır) yaparsanız uygulama her açıldığında
  // veritabanını silip baştan oluşturur (Reset Mode).
  // Normal kullanım ve güncellemeler için 1 veya üzeri yapın.
  static const _databaseVersion = 3;

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

  // ✅ YENİ: Fabrika ayarlarına dönme fonksiyonu
  @override
  Future<void> factoryReset() async {
    // 1. Mevcut bağlantıyı kapat
    await close();

    // 2. Dosya yolunu bul
    final path = await getDatabasePath(_databaseName);

    // 3. Veritabanı dosyasını fiziksel olarak sil
    final file = File(path);
    if (await file.exists()) {
      await deleteDatabase(path); // sqflite'ın silme metodu daha güvenlidir
      if (kDebugMode) print('🗑️ Veritabanı dosyası silindi: $path');
    }

    // 4. Veritabanını yeniden başlat (Bu işlem onCreate'i tetikler ve DbDefaults çalışır)
    _database = await _initDB(_databaseName);

    if (kDebugMode)
      print('✨ Fabrika ayarlarına dönüldü ve varsayılan veriler yüklendi.');
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

    if (kDebugMode) print('📦 Veritabanı Yolu: $path');

    // ✅ YENİ MANTIK: Versiyon 0 ise "Reset Mode" aktif
    if (_databaseVersion == 0) {
      if (kDebugMode) {
        print(
            '⚠️ DİKKAT: Veritabanı versiyonu 0! Mevcut veritabanı SİLİNİYOR ve YENİDEN OLUŞTURULUYOR...');
      }
      // Mevcut veritabanını tamamen sil
      await deleteDatabase(path);
    }

    return await openDatabase(
      path,
      // Eğer versiyon 0 ise, sqflite'ın onCreate'i tetiklemesi için 1 olarak açıyoruz.
      // Aksi takdirde (normal kullanımda) tanımlı versiyonu kullanıyoruz.
      version: _databaseVersion == 0 ? 1 : _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  static Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 🔄 Versiyon yükseltme işlemi (Sadece version > 0 ise ve artmışsa çalışır)
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print("♻️ Veritabanı güncelleniyor: v$oldVersion -> v$newVersion");
    }

    // ✅ DbSchema üzerinden tabloları düşür (veya migration scriptleri buraya yazılabilir)
    await DbSchema.dropTables(db);

    // ✅ Yeniden oluştur
    await _onCreate(db, newVersion);
  }

  /// 🧱 Veritabanı oluşturulduğunda çalışır
  static Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) print("🧱 Tablolar ve varsayılan veriler oluşturuluyor...");

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
}
