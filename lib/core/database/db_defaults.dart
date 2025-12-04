// lib/core/database/db_defaults.dart

import 'package:sqflite/sqflite.dart';
import '../../core/utils/security_helper.dart';

// Modeller (Tablo adlarına erişim için)
import '../../data/models/durum_model.dart';
import '../../data/models/kategori_model.dart';
import '../../data/models/oncelik_model.dart';
import '../../data/models/kullanicilar.dart';
import '../../data/models/not_model.dart';

class DbDefaults {
  static Future<void> insertDefaultData(Database db) async {
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

      // 🔹 KULLANICILAR (Şifre Hashlenerek)
      final hashedPassword = SecurityHelper.hashPassword('admin');
      await txn.insert(tableKullanicilar, {
        'ad': 'Admin',
        'soyad': 'User',
        'email': 'admin@gmail.com',
        'password': hashedPassword,
        'userName': 'admin',
        'cepTelefon': '',
        'fotoUrl': '',
      });

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
}
