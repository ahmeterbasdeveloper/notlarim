import '../../../core/abstract_db_service.dart';

// Domain
import '../../domain/entities/kontrol_liste.dart';
import '../../domain/repositories/kontrol_liste_repository.dart';

// Data
import '../models/kontrol_liste_model.dart';
import 'base_repository_impl.dart'; // ✅ Base Impl

class KontrolListeRepositoryImpl extends BaseRepositoryImpl<KontrolListe>
    implements KontrolListeRepository {
  KontrolListeRepositoryImpl(AbstractDBService dbService)
      : super(
          dbService,
          tableKontrolListe, // Model dosyasındaki tablo adı
          (json) => KontrolListeModel.fromJson(json), // Dönüştürücü
        );

  // ❌ create, update, delete vb. standart metodları SİLİN.

  // 👇 SADECE ÖZEL SORGULAR:
  @override
  Future<List<KontrolListe>> getByDurum(int durumId) async {
    final database = await db;
    final result = await database.query(
      tableName,
      where: '${KontrolListeAlanlar.durumId} = ?',
      whereArgs: [durumId],
    );
    return result.map((json) => fromMap(json)).toList();
  }
}
