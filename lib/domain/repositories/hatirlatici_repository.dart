import '../entities/hatirlatici.dart';

abstract class HatirlaticiRepository {
  Future<List<Hatirlatici>> getAllHatirlatici();
  Future<List<Hatirlatici>> getHatirlaticiByDurum(int durumId);
  Future<Hatirlatici> createHatirlatici(Hatirlatici hatirlatici);
  Future<int> updateHatirlatici(Hatirlatici hatirlatici);
  Future<int> deleteHatirlatici(int id);
}
