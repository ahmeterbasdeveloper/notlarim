import '../../entities/hatirlatici.dart';
import '../../repositories/hatirlatici_repository.dart';

class GetHatirlaticiById {
  final HatirlaticiRepository repository;

  GetHatirlaticiById(this.repository);

  /// Hatırlatıcıyı ID ile getir
  Future<Hatirlatici?> call(int id) async {
    final allHatirlaticilar = await repository.getAllHatirlatici();
    try {
      return allHatirlaticilar.firstWhere((h) => h.id == id);
    } catch (_) {
      return null; // ID bulunamazsa null döner
    }
  }
}
