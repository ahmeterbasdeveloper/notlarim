import '../entities/gorev.dart';

/// 🧩 Domain katmanındaki soyut repository arayüzü.
/// Sadece Entity ile çalışır — veritabanı veya model bilgisi içermez.
abstract class GorevRepository {
  Future<Gorev> getGorevById(int id);
  Future<List<Gorev>> getAllGorev();
  Future<Gorev> createGorev(Gorev gorev);
  Future<int> updateGorev(Gorev gorev);
  Future<int> deleteGorev(int id);
}
