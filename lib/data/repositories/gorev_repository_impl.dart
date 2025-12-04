import '../../../core/abstract_db_service.dart';

// Domain & Models
import '../../domain/entities/gorev.dart';
import '../../domain/repositories/gorev_repository.dart';
import '../models/gorev_model.dart';

// Base
import 'base_repository_impl.dart';

class GorevRepositoryImpl extends BaseRepositoryImpl<Gorev>
    implements GorevRepository {
  GorevRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableGorevler, // Model dosyasındaki tablo adı
          (json) => GorevModel.fromJson(json), // Dönüştürücü
        );

  // ❌ createGorev, updateGorev vb. metodları SİLİN.
}
