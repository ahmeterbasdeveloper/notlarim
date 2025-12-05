// lib/core/abstract_db_service.dart
abstract class AbstractDBService {
  Future<dynamic> getDatabaseInstance();
  Future<String> getDatabasePath(String dbName);
  Future<void> closeDatabase();
  Future<void> factoryReset(); //Fabrika ayarlarına dönme metodu tanımı
}
