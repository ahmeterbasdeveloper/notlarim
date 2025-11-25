import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import 'database_helper.dart'; // 🔹 DatabaseHelper sınıfına erişim
import 'database_update_notifier.dart';

/// Veritabanı Yedekleme ve Geri Yükleme Servisi
/// Bu sınıf, yedekleme işlemleri için DatabaseHelper ile koordineli çalışır.
class DatabaseBackupRestore {
  static final DatabaseBackupRestore instance = DatabaseBackupRestore._init();

  DatabaseBackupRestore._init();

  Database? _database;

  // 🔹 DatabaseHelper örneğine referans (AbstractDBService metodlarına erişim için)
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 📍 Aktif veritabanı nesnesini döndürür
  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    // 🟢 Yolu artık DatabaseHelper'dan alıyoruz. Kod tekrarı önlendi.
    final dbPath = await _dbHelper.getDatabasePath(AppConfig.databaseName);
    return await openDatabase(dbPath);
  }

  /// 🔒 Bu servisin kendi açık bağlantısını kapatır
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      if (kDebugMode) {
        print(
            '🧱 DatabaseBackupRestore: Yedekleme servisi veritabanı bağlantısı kapatıldı');
      }
    }
  }

  /// 📁 Yedeklerin tutulduğu dizini oluşturur veya döndürür
  Future<String> _getBackupDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final backupDir = Directory(join(dir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  /// 💾 Veritabanını yedekler
  Future<File?> backupDatabase({String? fileName}) async {
    try {
      // 🟢 Kaynak yolunu Helper'dan al
      final sourcePath =
          await _dbHelper.getDatabasePath(AppConfig.databaseName);
      final backupDir = await _getBackupDirectory();

      final backupFileName = fileName ??
          'notlar_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db';
      final backupPath = join(backupDir, backupFileName);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        if (kDebugMode) print('⚠️ Veritabanı dosyası bulunamadı: $sourcePath');
        return null;
      }

      // Veritabanı kilitli olabilir, kopyalamadan önce flush etmek iyi bir pratiktir ama
      // basit kullanımda doğrudan kopyalama genelde çalışır.
      final backupFile = await sourceFile.copy(backupPath);

      if (kDebugMode) print('✅ Yedek alındı: $backupPath');
      return backupFile;
    } catch (e) {
      if (kDebugMode) print('❌ Yedek alma hatası: $e');
      return null;
    }
  }

  /// ♻️ Yedekten geri yükleme yapar (veritabanını kapatıp yeniden açar)
  Future<bool> restoreDatabase(String fileName) async {
    try {
      // 1️⃣ Bu servisin aktif bağlantısını kapat
      await closeDatabase();

      // 2️⃣ Ana uygulamanın (DatabaseHelper) bağlantısını kapat
      try {
        // 🟢 AbstractDBService üzerinden gelen metodu kullanıyoruz
        await _dbHelper.closeDatabase();
        if (kDebugMode) print('🧱 DatabaseHelper bağlantısı kapatıldı');
      } catch (_) {}

      // 3️⃣ Dosya yollarını hazırla
      // 🟢 Hedef yol Helper'dan alınır
      final targetPath =
          await _dbHelper.getDatabasePath(AppConfig.databaseName);
      final backupDir = await _getBackupDirectory();
      final backupPath = join(backupDir, fileName);

      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        if (kDebugMode) {
          print('⚠️ Geri yüklenecek dosya bulunamadı: $backupPath');
        }
        return false;
      }

      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete(); // Eski db silinir
      }

      // 4️⃣ Yedeği kopyala
      await backupFile.copy(targetPath);

      // 5️⃣ Bu servisin veritabanı örneğini yenile (test amaçlı açıyoruz)
      _database = await openDatabase(targetPath);

      // 6️⃣ Ana uygulamanın (DatabaseHelper) bağlantısını yeniden başlat
      try {
        await _dbHelper.reopen();
        if (kDebugMode) {
          print('🔄 DatabaseHelper bağlantısı yeniden başlatıldı');
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              'ℹ️ DatabaseHelper reopen sırasında hata veya desteklenmiyor: $e');
        }
      }

      // ✅ Ek: Uygulama genelinde DB’nin değiştiğini bildirmek için event yayınla
      try {
        DatabaseUpdateNotifier.instance.notifyDatabaseChanged();
        if (kDebugMode) print('📢 Database güncellendi bildirimi gönderildi.');
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ DatabaseUpdateNotifier bildirimi başarısız: $e');
        }
      }

      if (kDebugMode) {
        print('✅ Yedek başarıyla geri yüklendi ve veritabanı yeniden açıldı.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Geri yükleme hatası: $e');
      return false;
    }
  }

  /// 📋 Mevcut yedekleri listeler
  Future<List<FileSystemEntity>> listBackups() async {
    try {
      final backupDirPath = await _getBackupDirectory();
      final dir = Directory(backupDirPath);
      if (!await dir.exists()) return [];
      return dir.listSync().whereType<File>().toList();
    } catch (e) {
      if (kDebugMode) print('❌ Yedek listeleme hatası: $e');
      return [];
    }
  }

  /// 🗑️ Belirli bir yedek dosyasını siler
  Future<void> deleteBackup(String fileName) async {
    try {
      final dirPath = await _getBackupDirectory();
      final file = File(join(dirPath, fileName));
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) print('🗑️ Yedek dosyası silindi: $fileName');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Yedek silme hatası: $e');
    }
  }

  /// Yedek dosyasını paylaşır (örnek: WhatsApp, e-posta, Drive vb.)
  static Future<void> shareBackupFile(String fileName) async {
    final backupDir =
        await DatabaseBackupRestore.instance._getBackupDirectory();
    final filePath = join(backupDir, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)],
          text: "📦 Notlarım uygulaması veritabanı yedeği");
    } else {
      debugPrint("⚠️ Yedek dosyası bulunamadı: $filePath");
    }
  }

  Future<String> copyToBackupFolder(File sourceFile) async {
    try {
      // ✅ Backup klasörünü al
      final backupDirPath = await _getBackupDirectory();
      final backupDir = Directory(backupDirPath);

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final newPath = join(backupDir.path, sourceFile.uri.pathSegments.last);
      final newFile = await sourceFile.copy(newPath);

      if (kDebugMode) print('📦 Yedek kopyalandı: ${newFile.path}');
      return newFile.path;
    } catch (e) {
      if (kDebugMode) print('❌ copyToBackupFolder hatası: $e');
      rethrow;
    }
  }
}
