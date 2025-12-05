// lib/core/database/db_defaults.dart

import 'package:sqflite/sqflite.dart';
import '../../core/utils/security_helper.dart';

// Modeller (Tablo adlarına erişim için)
import '../../features/durumlar/data/models/durum_model.dart';
import '../../features/kategoriler/data/models/kategori_model.dart';
import '../../features/oncelik/data/models/oncelik_model.dart';
import '../../features/kullanicilar/data/models/kullanicilar.dart';
import '../../features/notlar/data/models/not_model.dart';
import '../../features/gorevler/data/models/gorev_model.dart';
import '../../features/hatirlaticilar/data/models/hatirlatici_model.dart';
import '../../features/kontrol_listesi/data/models/kontrol_liste_model.dart';

class DbDefaults {
  static Future<void> insertDefaultData(Database db) async {
    await db.transaction((txn) async {
      final now = DateTime.now();
      final String nowIso = now.toIso8601String();

      // -----------------------------------------------------------------------
      // 🔹 1. DURUMLAR (Status)
      // -----------------------------------------------------------------------
      final durumlar = [
        {
          'baslik': 'Yeni',
          'aciklama': 'Yapılacak İş',
          'renkKodu': '#E2945B',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Süreç Devam Ediyor',
          'aciklama': 'İş başladı ve devam ediyor.',
          'renkKodu': '#AB582C',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Süresi Belirsiz',
          'aciklama': 'Belli bir süresi olmayan',
          'renkKodu': '#35D217',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Bilgi Talep Edildi',
          'aciklama': 'Bilgi talebinde bulunuldu',
          'renkKodu': '#35D217',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Bilgi Dönüşü Sağlandı',
          'aciklama': 'Bilgi Dönüşü Sağlandı',
          'renkKodu': '#35D217',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Tamamlandı',
          'aciklama': 'Tamamlanan İş',
          'renkKodu': '#39C73F',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'İptal Edildi',
          'aciklama': 'İşten vazgeçildi.',
          'renkKodu': '#F067B0',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
      ];
      for (final e in durumlar) {
        await txn.insert(tableDurumlar, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 2. KATEGORİLER (Categories)
      // -----------------------------------------------------------------------
      final kategoriler = [
        {
          'baslik': 'Genel',
          'aciklama': 'Genel konular',
          'renkKodu': '#9E9E9E',
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'İş',
          'aciklama': 'İş ile ilgili notlar',
          'renkKodu': '#2196F3',
          'kayitZamani': nowIso,
          'sabitMi': 0
        },
        {
          'baslik': 'Kişisel',
          'aciklama': 'Kişisel notlar',
          'renkKodu': '#FF9800',
          'kayitZamani': nowIso,
          'sabitMi': 0
        },
        {
          'baslik': 'Alışveriş',
          'aciklama': 'Alışveriş listeleri',
          'renkKodu': '#E91E63',
          'kayitZamani': nowIso,
          'sabitMi': 0
        },
        {
          'baslik': 'Eğitim',
          'aciklama': 'Ders ve eğitim notları',
          'renkKodu': '#9C27B0',
          'kayitZamani': nowIso,
          'sabitMi': 0
        },
      ];
      for (final e in kategoriler) {
        await txn.insert(tableKategoriler, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 3. ÖNCELİKLER (Priorities)
      // -----------------------------------------------------------------------
      final oncelikler = [
        {
          'baslik': 'Önemsiz',
          'aciklama': 'Öncelik Önemsiz',
          'renkKodu': '#B0BEC5', // Gri
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Düşük',
          'aciklama': 'Öncelik Düşük',
          'renkKodu': '#81C784', // Yeşil
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Orta',
          'aciklama': 'Öncelik Orta',
          'renkKodu': '#FFD54F', // Sarı
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Yüksek',
          'aciklama': 'Öncelik Yüksek',
          'renkKodu': '#FF8A65', // Turuncu
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
        {
          'baslik': 'Acil',
          'aciklama': 'Öncelik Acil',
          'renkKodu': '#E57373', // Kırmızı
          'kayitZamani': nowIso,
          'sabitMi': 1
        },
      ];
      for (final e in oncelikler) {
        await txn.insert(tableOncelik, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 4. KULLANICILAR (Users)
      // -----------------------------------------------------------------------
      final hashedPassword = SecurityHelper.hashPassword('admin');
      final hashedSecurityCode = SecurityHelper.hashPassword('admin');
      await txn.insert(tableKullanicilar, {
        'ad': 'Admin',
        'soyad': 'User',
        'email': 'admin@gmail.com',
        'password': hashedPassword,
        'userName': 'admin',
        'cepTelefon': '',
        'fotoUrl': '',
        'GuvenlikKodu': hashedSecurityCode,
      });

      // -----------------------------------------------------------------------
      // 🔹 5. NOTLAR (Notes) - Çoklu Ekleme
      // -----------------------------------------------------------------------
      final notlar = [
        {
          'kategoriId': 1, // Genel
          'oncelikId': 3, // Orta
          'baslik': 'Uygulamaya Hoş Geldiniz',
          'aciklama':
              'Bu not uygulaması ile günlük işlerinizi, notlarınızı ve görevlerinizi kolayca takip edebilirsiniz.',
          'kayitZamani': nowIso,
          'durumId': 1,
        },
        {
          'kategoriId': 2, // İş
          'oncelikId': 5, // Acil
          'baslik': 'Proje Toplantısı',
          'aciklama':
              'Pazartesi günü saat 10:00\'da yapılacak proje toplantısı için sunum hazırlanacak.',
          'kayitZamani': now.add(const Duration(hours: 1)).toIso8601String(),
          'durumId': 2, // Süreç Devam Ediyor
        },
        {
          'kategoriId': 4, // Alışveriş
          'oncelikId': 2, // Düşük
          'baslik': 'Market Listesi',
          'aciklama': 'Süt, Yumurta, Ekmek, Peynir alınacak.',
          'kayitZamani': now.add(const Duration(days: 1)).toIso8601String(),
          'durumId': 1,
        },
        {
          'kategoriId': 3, // Kişisel
          'oncelikId': 4, // Yüksek
          'baslik': 'Spor Salonu Üyeliği',
          'aciklama': 'Üyelik yenileme tarihi yaklaşıyor, kontrol et.',
          'kayitZamani': now.add(const Duration(days: 2)).toIso8601String(),
          'durumId': 1,
        },
      ];
      for (final e in notlar) {
        await txn.insert(tableNotlar, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 6. GÖREVLER (Tasks) - Çoklu Ekleme
      // -----------------------------------------------------------------------
      final gorevler = [
        {
          'grupId': 0,
          'baslik': 'Rapor Hazırla',
          'aciklama': 'Aylık satış raporlarını excel formatında hazırla.',
          'kategoriId': 2, // İş
          'oncelikId': 4, // Yüksek
          'baslamaTarihiZamani': nowIso,
          'bitisTarihiZamani':
              now.add(const Duration(days: 3)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 2,
        },
        {
          'grupId': 0,
          'baslik': 'Faturaları Öde',
          'aciklama': 'Elektrik ve su faturalarının son ödeme tarihi.',
          'kategoriId': 3, // Kişisel
          'oncelikId': 5, // Acil
          'baslamaTarihiZamani': nowIso,
          'bitisTarihiZamani':
              now.add(const Duration(days: 1)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 1,
        },
        {
          'grupId': 0,
          'baslik': 'Kitap Oku',
          'aciklama': 'Günde en az 30 sayfa kitap okunacak.',
          'kategoriId': 5, // Eğitim
          'oncelikId': 3, // Orta
          'baslamaTarihiZamani': nowIso,
          'bitisTarihiZamani':
              now.add(const Duration(days: 30)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 2,
        },
      ];
      for (final e in gorevler) {
        await txn.insert(tableGorevler, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 7. HATIRLATICILAR (Reminders) - Çoklu Ekleme
      // -----------------------------------------------------------------------
      final hatirlaticilar = [
        {
          'baslik': 'Dişçi Randevusu',
          'aciklama': 'Yıllık kontrol.',
          'kategoriId': 3, // Kişisel
          'oncelikId': 4, // Yüksek
          'hatirlatmaTarihiZamani':
              now.add(const Duration(days: 5, hours: 14)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 1,
        },
        {
          'baslik': 'İlaç Saati',
          'aciklama': 'Vitaminlerini almayı unutma.',
          'kategoriId': 3, // Kişisel
          'oncelikId': 5, // Acil
          'hatirlatmaTarihiZamani':
              now.add(const Duration(hours: 4)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 1,
        },
        {
          'baslik': 'Doğum Günü',
          'aciklama': 'Arkadaşının doğum gününü kutla.',
          'kategoriId': 1, // Genel
          'oncelikId': 3, // Orta
          'hatirlatmaTarihiZamani':
              now.add(const Duration(days: 10)).toIso8601String(),
          'kayitZamani': nowIso,
          'durumId': 1,
        },
      ];
      for (final e in hatirlaticilar) {
        await txn.insert(tableHatirlaticilar, e);
      }

      // -----------------------------------------------------------------------
      // 🔹 8. KONTROL LİSTESİ (Checklist) - Çoklu Ekleme
      // -----------------------------------------------------------------------
      final kontrolListeleri = [
        {
          'baslik': 'Tatil Hazırlığı',
          'aciklama': 'Pasaport kontrolü, biletler, otel rezervasyonu.',
          'kategoriId': 3, // Kişisel
          'oncelikId': 3, // Orta
          'kayitZamani': nowIso,
          'durumId': 1,
        },
        {
          'baslik': 'Araç Bakımı',
          'aciklama': 'Yağ değişimi, lastik kontrolü, silecek suyu.',
          'kategoriId': 1, // Genel
          'oncelikId': 2, // Düşük
          'kayitZamani': nowIso,
          'durumId': 1,
        },
      ];
      for (final e in kontrolListeleri) {
        await txn.insert(tableKontrolListe, e);
      }
    });
  }
}
