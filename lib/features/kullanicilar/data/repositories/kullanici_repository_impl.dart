import 'package:sqflite/sqflite.dart';
import '../../../../../core/abstract_db_service.dart';
import '../../../../../core/utils/security_helper.dart';

// Domain & Model
import '../../domain/repositories/kullanici_repository.dart';
import '../models/kullanicilar.dart';

class KullaniciRepositoryImpl implements KullaniciRepository {
  final AbstractDBService _dbService;

  KullaniciRepositoryImpl(this._dbService);

  // 1. GİRİŞ YAP
  @override
  Future<bool> login(String userName, String password) async {
    final Database db = await _dbService.getDatabaseInstance();
    final String hashedPassword = SecurityHelper.hashPassword(password);

    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where:
          '${KullaniciAlanlar.userName} = ? AND ${KullaniciAlanlar.password} = ?',
      whereArgs: [userName, hashedPassword],
    );
    return maps.isNotEmpty;
  }

  // 2. KULLANICI DOĞRULAMA (Şifremi Unuttum İçin - GÜNCELLENDİ)
  @override
  Future<bool> verifyUser(String userName, String securityCode) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Güvenlik kodunu hashliyoruz (DB'de hashli saklandığı için)
    final String hashedCode = SecurityHelper.hashPassword(securityCode);

    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where:
          '${KullaniciAlanlar.userName} = ? AND ${KullaniciAlanlar.guvenlikKodu} = ?',
      whereArgs: [userName, hashedCode],
    );

    return maps.isNotEmpty;
  }

  // ... (Diğer metodlar updatePassword, verifySecurityCode, updateSecurityCode aynı kalacak)
  // ...

  @override
  Future<void> updatePassword(String userName, String newPassword) async {
    final Database db = await _dbService.getDatabaseInstance();
    final String hashedPassword = SecurityHelper.hashPassword(newPassword);
    await db.update(
      'kullanicilar',
      {KullaniciAlanlar.password: hashedPassword},
      where: '${KullaniciAlanlar.userName} = ?',
      whereArgs: [userName],
    );
  }

  @override
  Future<bool> verifySecurityCode(String userName, String securityCode) async {
    final Database db = await _dbService.getDatabaseInstance();
    final String hashedCode = SecurityHelper.hashPassword(securityCode);
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where:
          '${KullaniciAlanlar.userName} = ? AND ${KullaniciAlanlar.guvenlikKodu} = ?',
      whereArgs: [userName, hashedCode],
    );
    return maps.isNotEmpty;
  }

  @override
  Future<void> updateSecurityCode(String userName, String newCode) async {
    final Database db = await _dbService.getDatabaseInstance();
    final String hashedCode = SecurityHelper.hashPassword(newCode);
    await db.update(
      'kullanicilar',
      {KullaniciAlanlar.guvenlikKodu: hashedCode},
      where: '${KullaniciAlanlar.userName} = ?',
      whereArgs: [userName],
    );
  }
}
