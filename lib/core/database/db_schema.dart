// lib/core/database/db_schema.dart

import 'package:sqflite/sqflite.dart';

// Modeller (Tablo ve Kolon isimlerine erişim için)
import '../../data/models/durum_model.dart';
import '../../data/models/kategori_model.dart';
import '../../data/models/oncelik_model.dart';
import '../../data/models/kullanicilar.dart';
import '../../data/models/not_model.dart';
import '../../data/models/kontrol_liste_model.dart';
import '../../data/models/gorev_model.dart';
import '../../data/models/hatirlatici_model.dart';

class DbSchema {
  // Sabit SQL Tipleri
  static const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const textType = 'TEXT NOT NULL';
  static const integerType = 'INTEGER NOT NULL';

  /// Tüm tabloları oluşturur
  static Future<void> createTables(Database db) async {
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
        ${KullaniciAlanlar.userName} $textType,
        ${KullaniciAlanlar.cepTelefon} $textType,
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
  }

  /// Tüm tabloları siler (Upgrade senaryosu için)
  static Future<void> dropTables(Database db) async {
    await db.execute("DROP TABLE IF EXISTS $tableDurumlar");
    await db.execute("DROP TABLE IF EXISTS $tableKategoriler");
    await db.execute("DROP TABLE IF EXISTS $tableOncelik");
    await db.execute("DROP TABLE IF EXISTS $tableKullanicilar");
    await db.execute("DROP TABLE IF EXISTS $tableNotlar");
    await db.execute("DROP TABLE IF EXISTS $tableKontrolListe");
    await db.execute("DROP TABLE IF EXISTS $tableGorevler");
    await db.execute("DROP TABLE IF EXISTS $tableHatirlaticilar");
  }
}
