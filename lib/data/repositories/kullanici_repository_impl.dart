// ... mevcut importlar
import 'package:notlarim/core/abstract_db_service.dart';
import 'package:notlarim/data/models/kullanicilar.dart';
import 'package:notlarim/domain/repositories/kullanici_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/security_helper.dart'; // Hashleme için gerekli

class KullaniciRepositoryImpl implements KullaniciRepository {
  final AbstractDBService _dbService;

  KullaniciRepositoryImpl(this._dbService);

  @override
  Future<bool> login(String userName, String password) async {
    // ... eski kodlarınız aynı kalsın ...
    // (Burayı silmeyin, olduğu gibi kalsın)
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

  // 👇 1. KULLANICI DOĞRULAMA (Username + Email eşleşiyor mu?)
  @override
  Future<bool> verifyUser(String userName, String email) async {
    final Database db = await _dbService.getDatabaseInstance();

    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where:
          '${KullaniciAlanlar.userName} = ? AND ${KullaniciAlanlar.email} = ?',
      whereArgs: [userName, email],
    );

    return maps.isNotEmpty;
  }

  // 👇 2. ŞİFRE GÜNCELLEME
  @override
  Future<void> updatePassword(String userName, String newPassword) async {
    final Database db = await _dbService.getDatabaseInstance();

    // Yeni şifreyi hashliyoruz
    final String hashedPassword = SecurityHelper.hashPassword(newPassword);

    await db.update(
      'kullanicilar',
      {KullaniciAlanlar.password: hashedPassword},
      where: '${KullaniciAlanlar.userName} = ?',
      whereArgs: [userName],
    );
  }
}
