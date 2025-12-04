import 'package:flutter_riverpod/legacy.dart';

/// Uygulamadaki aktif ekranları temsil eden enum
enum ActiveScreen {
  gorevler,
  durumlar,
  kategoriler,
  notlar,
  oncelikler,
}

/// Aktif ekranı yöneten provider
final activeScreenProvider = StateProvider<ActiveScreen>((ref) {
  return ActiveScreen.notlar; // varsayılan ekran
});
