// lib/features/notes/domain/repositories/durum_repository.dart

import '../entities/durum.dart';

/// Domain katmanındaki soyut repository arayüzü.
/// Sadece Entity ile çalışır — veritabanı veya model bilgisi içermez.
abstract class DurumRepository {
  Future<Durum> getDurumById(int id);
  Future<List<Durum>> getAllDurum();
  Future<Durum> createDurum(Durum durum);
  Future<int> updateDurum(Durum durum);
  Future<int> deleteDurum(int id);
}
