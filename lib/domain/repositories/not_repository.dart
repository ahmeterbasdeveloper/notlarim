// lib/domain/repositories/not_repository.dart

import '../entities/not.dart';
import 'base_repository.dart'; // ✅ BaseRepository import edilmeli

/// Domain Katmanında: Repository Interface
/// ✅ BaseRepository<Not>'tan miras alarak standart CRUD işlemlerini otomatik kazanır.
abstract class NotRepository extends BaseRepository<Not> {
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
