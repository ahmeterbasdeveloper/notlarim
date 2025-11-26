import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:sqflite/sqflite.dart';
import '../../../core/abstract_db_service.dart';
import '../../domain/repositories/kullanici_repository.dart';
import '../models/kullanicilar.dart';
import '../../../core/utils/security_helper.dart';

class KullaniciRepositoryImpl implements KullaniciRepository {
  final AbstractDBService _dbService;

  KullaniciRepositoryImpl(this._dbService);

  @override
  Future<bool> login(String email, String password) async {
    final Database db = await _dbService.getDatabaseInstance();

    // 1. Gelen şifreyi hashle
    final String hashedPassword = SecurityHelper.hashPassword(password);

    debugPrint('🔐 Girilen Şifre (Plain): $password');
    debugPrint('🔐 Aranacak Hash: $hashedPassword');

    // 2. Veritabanında hashlenmiş şifreyi ara
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where:
          '${KullaniciAlanlar.email} = ? AND ${KullaniciAlanlar.password} = ?',
      whereArgs: [email, hashedPassword],
    );

    // Hata ayıklama: Eğer boş dönüyorsa, o mail adresiyle kayıtlı ne var ona bakalım
    if (maps.isEmpty) {
      debugPrint(
          '⚠️ Eşleşme bulunamadı. Veritabanındaki bu mailin kaydına bakılıyor...');
      final checkUser = await db.query(
        'kullanicilar',
        where: '${KullaniciAlanlar.email} = ?',
        whereArgs: [email],
      );
      if (checkUser.isNotEmpty) {
        debugPrint(
            'ℹ️ Veritabanındaki Kayıtlı Hash: ${checkUser.first['password']}');
      } else {
        debugPrint('ℹ️ Bu email ile kayıtlı kullanıcı YOK.');
      }
    }

    return maps.isNotEmpty;
  }
}
