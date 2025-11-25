import '../../data/datasources/database_helper.dart';

class KullaniciHelper {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  ///*** KULLANICI ile ilgili Veritabanı İşlemleri ***

  Future<List<Map<String, dynamic>>> getKullanici() async {
    final db = await _databaseHelper.database;
    return await db.query('kullanicilar');
  }

  ///Kullanıcı Kayıt Ekleme İşlemi
  Future<void> insertKullanici(Map<String, dynamic> kullanici) async {
    final db = await _databaseHelper.database;
    await db.insert('kullanicilar', kullanici);
  }
}
