import 'package:flutter/foundation.dart';

/// Veritabanı güncellendiğinde UI'ye haber verir
class DatabaseUpdateNotifier extends ChangeNotifier {
  static final DatabaseUpdateNotifier instance = DatabaseUpdateNotifier._internal();
  DatabaseUpdateNotifier._internal();

  void notifyDatabaseChanged() {
    if (kDebugMode) print('📢 Database güncellendi bildirimi gönderildi.');
    notifyListeners();
  }
}
