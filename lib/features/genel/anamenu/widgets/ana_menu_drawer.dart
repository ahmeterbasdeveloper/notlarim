import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization.dart';

// Providers
import '../../../notlar/presentation/providers/not_providers.dart';
import '../../../kategoriler/presentation/providers/kategori_providers.dart';
import '../../../kontrol_listesi/presentation/providers/kontrol_liste_providers.dart';
import '../../../oncelik/presentation/providers/oncelik_providers.dart';
import '../../../hatirlaticilar/presentation/providers/hatirlatici_providers.dart';
import '../../../durumlar/presentation/providers/durum_providers.dart';

class AnaMenuDrawer extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final VoidCallback onLogoutTap;
  final VoidCallback onChangePasswordTap; // Callback eklendi
  final VoidCallback onChangeSecurityCodeTap; // Callback eklendi

  const AnaMenuDrawer({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onLogoutTap,
    required this.onChangePasswordTap,
    required this.onChangeSecurityCodeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // --- HEADER ---
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.green),
                  child: Text(
                    loc.translate('app_title'),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),

                // --- MENÜ ELEMANLARI ---
                _drawerItem(
                    context, ref, Icons.list, loc.translate('menu_notes'), 0),
                _drawerItem(context, ref, Icons.category,
                    loc.translate('menu_categories'), 1),
                _drawerItem(context, ref, Icons.list_alt,
                    loc.translate('menu_situations'), 2),
                _drawerItem(context, ref, Icons.priority_high,
                    loc.translate('menu_priorities'), 3),
                _drawerItem(context, ref, Icons.checklist,
                    loc.translate('menu_checklists'), 4),
                _drawerItem(context, ref, Icons.alarm,
                    loc.translate('general_reminder'), 5),

                // ✅ GÜVENLİK BÖLÜMÜ
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.blueGrey),
                  title: Text(loc.translate('menu_changeSecurityCode') ??
                      "Güvenlik Kodunu Değiştir"),
                  onTap: () {
                    Navigator.pop(context); // Drawer'ı kapat
                    onChangeSecurityCodeTap(); // Logic'teki fonksiyonu çağır
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.blueGrey),
                  title: Text(
                      loc.translate('menu_changePassword') ?? "Şifre Değiştir"),
                  onTap: () {
                    Navigator.pop(context); // Drawer'ı kapat
                    onChangePasswordTap(); // Logic'teki fonksiyonu çağır
                  },
                ),

                // ✅ ÇIKIŞ BÖLÜMÜ
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    loc.translate('menu_logout'),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onLogoutTap();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, WidgetRef ref, IconData icon,
      String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      selected: selectedIndex == index,
      selectedTileColor: Colors.grey.shade200,
      onTap: () {
        Navigator.pop(context);
        onIndexChanged(index);
        _refreshPageData(ref, index);
      },
    );
  }

  void _refreshPageData(WidgetRef ref, int index) {
    switch (index) {
      case 0:
        ref.invalidate(notNotifierProvider);
        break;
      case 1:
        ref.invalidate(kategoriNotifierProvider);
        break;
      case 2:
        ref.invalidate(durumNotifierProvider);
        break;
      case 3:
        ref.invalidate(oncelikNotifierProvider);
        break;
      case 4:
        ref.invalidate(kontrolListeNotifierProvider);
        break;
      case 5:
        ref.invalidate(hatirlaticiNotifierProvider);
        break;
    }
  }
}
