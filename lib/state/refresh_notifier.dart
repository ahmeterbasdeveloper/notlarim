import 'package:flutter/foundation.dart';

/// 🔔 Not listesi veya diğer sayfaları yenilemek için global notifier
class RefreshNotifier {
  static final RefreshNotifier instance = RefreshNotifier._internal();
  RefreshNotifier._internal();

  final ValueNotifier<bool> notListChanged = ValueNotifier(false);

  /// Listeyi yenilemek için çağır
  void notifyNotListChanged() {
    notListChanged.value = !notListChanged.value; // Toggle her seferinde
  }
}
