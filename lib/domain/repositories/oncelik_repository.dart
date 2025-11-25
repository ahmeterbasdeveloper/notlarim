import '../entities/oncelik.dart';

/// 🧩 Domain katmanındaki soyut repository arayüzü.
/// Sadece Entity ile çalışır — veritabanı veya model bilgisi içermez.
abstract class OncelikRepository {
  /// Veritabanındaki ilk önceliği döndürür.
  Future<Oncelik> getIlkOncelik();

  /// ID’ye göre tek bir önceliği döndürür.
  Future<Oncelik> getOncelikById(int id);

  /// Tüm öncelikleri listeler.
  Future<List<Oncelik>> getAllOncelik();

  /// Yeni bir öncelik oluşturur.
  Future<Oncelik> createOncelik(Oncelik oncelik);

  /// Var olan bir önceliği günceller.
  Future<int> updateOncelik(Oncelik oncelik);

  /// ID’ye göre bir önceliği siler.
  Future<int> deleteOncelik(int id);
}
