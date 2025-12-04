import '../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/oncelik.dart';
import '../../domain/repositories/oncelik_repository.dart';

// Data
import '../models/oncelik_model.dart';
import 'base_repository_impl.dart'; // ✅ Base Impl

class OncelikRepositoryImpl extends BaseRepositoryImpl<Oncelik>
    implements OncelikRepository {
  OncelikRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableOncelik, // Model dosyasındaki tablo adı
          (json) => OncelikModel.fromJson(json), // Dönüştürücü
        );

  // ❌ Standard CRUD metodlarını SİLİN.

  // 👇 SADECE ÖZEL METODLAR:
  @override
  Future<Oncelik> getIlkOncelik() async {
    final database = await db;
    final result = await database.query(
      tableName,
      orderBy: '${OncelikAlanlar.id} ASC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return fromMap(result.first);
    } else {
      throw Exception('Hiç öncelik bulunamadı.');
    }
  }
}
