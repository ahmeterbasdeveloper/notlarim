// lib/data/repositories/durum_repository_impl.dart
import '../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/durum.dart';
import '../../domain/repositories/durum_repository.dart';

// Data
import '../models/durum_model.dart';
import 'base_repository_impl.dart'; // ✅ Base Impl

class DurumRepositoryImpl extends BaseRepositoryImpl<Durum>
    implements DurumRepository {
  DurumRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableDurumlar, // Model dosyasındaki tablo adı sabiti
          (json) => DurumModel.fromJson(json), // Dönüştürücü fonksiyon
        );

  // ❌ createDurum, updateDurum vb. tüm metodları SİLİN.
  // BaseRepositoryImpl hepsini hallediyor.
}
