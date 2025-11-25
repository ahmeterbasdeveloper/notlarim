import 'package:flutter/foundation.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// 🟢 Soyut arayüzü (interface)
import '../../core/abstract_db_service.dart';

// Modeller
import '../models/hatirlatici_model.dart';
import '../models/kategori_model.dart';
import '../models/kullanicilar.dart';
import '../models/not_model.dart';
import '../models/kontrol_liste_model.dart';
import '../models/oncelik_model.dart';
import '../models/durum_model.dart';
import '../models/gorev_model.dart';

/// DatabaseHelper sınıfı AbstractDBService arayüzünü uygular.
class DatabaseHelper implements AbstractDBService {
  /// Eğer 1 ise getApplicationDocumentsDirectory, 2 ise getDatabasesPath kullanılır
  static int pathDbDirectoryTip = 2;

  static const _databaseName = "notlar.db";

  // 🚨 ÖNEMLİ DEĞİŞİKLİK: Versiyonu 2 yaptık.
  // Bu sayede onUpgrade çalışacak ve tabloları yeniden oluşturup verileri getirecek.
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
      onCreate: _onCreate, // İlk kurulumda çalışır
      onUpgrade:
          _onUpgrade, // Versiyon değişince çalışır (Verileri düzeltmek için)
      onOpen: _onOpen,
    );
  }

  static Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 🔄 Versiyon yükseltme işlemi (Veriler gelmiyorsa burası tetiklenir)
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (kDebugMode)
      print("♻️ Veritabanı güncelleniyor: v$oldVersion -> v$newVersion");

    // Tüm tabloları sil (Temiz başlangıç için)
    await db.execute("DROP TABLE IF EXISTS $tableDurumlar");
    await db.execute("DROP TABLE IF EXISTS $tableKategoriler");
    await db.execute("DROP TABLE IF EXISTS $tableOncelik");
    await db.execute("DROP TABLE IF EXISTS $tableKullanicilar");
    await db.execute("DROP TABLE IF EXISTS $tableNotlar");
    await db.execute("DROP TABLE IF EXISTS $tableKontrolListe");
    await db.execute("DROP TABLE IF EXISTS $tableGorevler");
    await db.execute("DROP TABLE IF EXISTS $tableHatirlaticilar");

    // Tabloları ve verileri yeniden oluştur
    await _onCreate(db, newVersion);
  }

  /// 🧱 Veritabanı tablolarını oluştur
  static Future<void> _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableDurumlar ( 
        ${DurumAlanlar.id} $idType, 
        ${DurumAlanlar.baslik} $textType,
        ${DurumAlanlar.aciklama} $textType,
        ${DurumAlanlar.renkKodu} $textType,
        ${DurumAlanlar.kayitZamani} $textType,
        ${DurumAlanlar.sabitMi} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableKategoriler  ( 
        ${KategoriAlanlar.id} $idType, 
        ${KategoriAlanlar.baslik} $textType,
        ${KategoriAlanlar.aciklama} $textType,
        ${KategoriAlanlar.renkKodu} $textType,
        ${KategoriAlanlar.kayitZamani} $textType,
        ${KategoriAlanlar.sabitMi} $integerType 
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOncelik ( 
        ${OncelikAlanlar.id} $idType, 
        ${OncelikAlanlar.baslik} $textType,
        ${OncelikAlanlar.aciklama} $textType,
        ${OncelikAlanlar.renkKodu} $textType,
        ${OncelikAlanlar.kayitZamani} $textType,
        ${OncelikAlanlar.sabitMi} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableKullanicilar ( 
        ${KullaniciAlanlar.id} $idType, 
        ${KullaniciAlanlar.ad} $textType,
        ${KullaniciAlanlar.soyad} $textType,
        ${KullaniciAlanlar.email} $textType,
        ${KullaniciAlanlar.password} $textType,
        ${KullaniciAlanlar.fotoUrl} $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotlar ( 
        ${NotAlanlar.id} $idType, 
        ${NotAlanlar.kategoriId} $integerType,
        ${NotAlanlar.oncelikId} $integerType,
        ${NotAlanlar.baslik} $textType,
        ${NotAlanlar.aciklama} $textType,
        ${NotAlanlar.kayitZamani} $textType,
        ${NotAlanlar.durumId} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableKontrolListe ( 
        ${KontrolListeAlanlar.id} $idType, 
        ${KontrolListeAlanlar.baslik} $textType,
        ${KontrolListeAlanlar.aciklama} $textType,
        ${KontrolListeAlanlar.kategoriId} $integerType,
        ${KontrolListeAlanlar.oncelikId} $integerType,
        ${KontrolListeAlanlar.kayitZamani} $textType,
        ${KontrolListeAlanlar.durumId} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableGorevler ( 
        ${GorevAlanlar.id} $idType, 
        ${GorevAlanlar.grupId} $integerType,
        ${GorevAlanlar.baslik} $textType,
        ${GorevAlanlar.aciklama} $textType,
        ${GorevAlanlar.kategoriId} $integerType,
        ${GorevAlanlar.oncelikId} $integerType,
        ${GorevAlanlar.baslamaTarihiZamani} $textType,
        ${GorevAlanlar.bitisTarihiZamani} $textType,
        ${GorevAlanlar.kayitZamani} $textType,
        ${GorevAlanlar.durumId} $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableHatirlaticilar  ( 
        ${HatirlaticiAlanlar.id} $idType, 
        ${HatirlaticiAlanlar.baslik} $textType,
        ${HatirlaticiAlanlar.aciklama} $textType,
        ${HatirlaticiAlanlar.kategoriId} $integerType,
        ${HatirlaticiAlanlar.oncelikId} $integerType,
        ${HatirlaticiAlanlar.hatirlatmaTarihiZamani} $textType,
        ${HatirlaticiAlanlar.kayitZamani} $textType,
        ${HatirlaticiAlanlar.durumId} $integerType
      )
    ''');

    // Varsayılan kayıtları ekle
    await _insertDefaults(db);
  }

  /// Varsayılan örnek veriler
  static Future<void> _insertDefaults(Database db) async {
    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();

      // 🔹 Durumlar
      final durumlar = [
        {
          'baslik': 'Yeni',
          'aciklama': 'Yapılacak İş',
          'renkKodu': '#E2945B',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Süreç Devam Ediyor',
          'aciklama': 'İş başladı ve devam ediyor.',
          'renkKodu': '#AB582C',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Süresi Belirsiz',
          'aciklama': 'Belli bir süresi olmayan',
          'renkKodu': '#35D217',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Tamamlandı',
          'aciklama': 'Tamamlanan İş',
          'renkKodu': '#39C73F',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'İptal Edildi',
          'aciklama': 'İşten vazgeçildi.',
          'renkKodu': '#F067B0',
          'kayitZamani': now,
          'sabitMi': 1
        },
      ];
      for (final e in durumlar) {
        await txn.insert(tableDurumlar, e);
      }

      // 🔹 Kategoriler
      final kategoriler = [
        {
          'baslik': 'Özel',
          'aciklama': 'Özel İşler',
          'renkKodu': '#55DC67',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Alışveriş',
          'aciklama': 'Alışveriş İşleri',
          'renkKodu': '#70DCFF',
          'kayitZamani': now,
          'sabitMi': 0
        },
      ];
      for (final e in kategoriler) {
        await txn.insert(tableKategoriler, e);
      }

      // 🔹 Öncelikler
      final oncelikler = [
        {
          'baslik': 'Önemsiz',
          'aciklama': 'Öncelik Önemsiz',
          'renkKodu': '#DFD293',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Düşük',
          'aciklama': 'Öncelik Düşük',
          'renkKodu': '#E1D37D',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Orta',
          'aciklama': 'Öncelik Orta',
          'renkKodu': '#AACB70',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Yüksek',
          'aciklama': 'Öncelik Yüksek',
          'renkKodu': '#73C25F',
          'kayitZamani': now,
          'sabitMi': 1
        },
        {
          'baslik': 'Acil',
          'aciklama': 'Öncelik Acil',
          'renkKodu': '#E4354F',
          'kayitZamani': now,
          'sabitMi': 1
        },
      ];
      for (final e in oncelikler) {
        await txn.insert(tableOncelik, e);
      }

      // 🔹 Örnek Not
      await txn.insert(tableNotlar, {
        'kategoriId': 1,
        'oncelikId': 1,
        'baslik': 'İlk Not Başlığı',
        'aciklama': 'İlk not açıklaması',
        'kayitZamani': now,
        'durumId': 1,
      });
    });
  }

  /// 📌 Tablo var mı kontrolü (Eski kodlardan kalma, onCreate içinde artık gerek yok ama silmedim)
  static Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// 🔒 Bağlantıyı kapatır
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      if (kDebugMode)
        print('🧱 DatabaseHelper: Veritabanı bağlantısı kapatıldı');
    }
  }

  /// 🔁 Bağlantıyı yeniden açar (yedekten sonra kullanılır)
  Future<void> reopen() async {
    await close();
    _database = await _initDB(_databaseName);
    if (kDebugMode)
      print('🔄 DatabaseHelper: Veritabanı bağlantısı yeniden açıldı');
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
