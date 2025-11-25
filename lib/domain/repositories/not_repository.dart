import '../entities/not.dart';

/// Domain Katmanında: yalnızca soyutlama (interface) bulunur.
/// Veri kaynağı (SQLite, API, vb.) burada bilinmez.
abstract class NotRepository {
  /// ID’ye göre not getir
  Future<Not?> getNotById(int id);

  /// Tüm notları getir
  Future<List<Not>> getAllNotlar();

  /// Başlığa göre arama
  Future<List<Not>> searchNotlar(String searchText);

  /// Kategoriye göre filtreleme
  Future<List<Not>> getNotlarByKategori(int kategoriId);

  /// Önceliğe göre filtreleme
  Future<List<Not>> getNotlarByOncelik(int oncelikId);

  /// Duruma göre filtreleme
  Future<List<Not>> getNotlarByDurum(int durumId);

  /// Yeni not oluştur
  Future<Not> createNot(Not not);

  /// Not güncelle
  Future<int> updateNot(Not not);

  /// Not sil
  Future<int> deleteNot(int id);
}
