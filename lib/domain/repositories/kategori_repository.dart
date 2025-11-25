import '../entities/kategori.dart';

/// Domain katmanındaki soyut repository arayüzü.
/// Sadece Entity ile çalışır — veritabanı veya model bilgisi içermez.
abstract class KategoriRepository {
  Future<Kategori> getIlkKategori();
  Future<Kategori> getKategoriById(int id);
  Future<List<Kategori>> getAllKategori();
  Future<Kategori> createKategori(Kategori kategori);
  Future<int> updateKategori(Kategori kategori);
  Future<int> deleteKategori(int id);
}
