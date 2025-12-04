// lib/domain/repositories/not_repository.dart

import '../entities/not.dart';
import '../../../../core/base/crud_repository.dart';

/// Domain Katmanında: Repository Interface
/// ✅ BaseRepository<Not>'tan miras alarak standart CRUD işlemlerini otomatik kazanır.
abstract class NotRepository extends CrudRepository<Not> {
  // 👇 Sadece Not Entity'sine özel (Generic olmayan) iş mantığı metodları kalmalı:

  /// Başlığa göre arama
  Future<List<Not>> searchNotlar(String searchText);

  /// Kategoriye göre filtreleme
  Future<List<Not>> getNotlarByKategori(int kategoriId);

  /// Önceliğe göre filtreleme
  Future<List<Not>> getNotlarByOncelik(int oncelikId);

  /// Duruma göre filtreleme
  Future<List<Not>> getNotlarByDurum(int durumId);
}
