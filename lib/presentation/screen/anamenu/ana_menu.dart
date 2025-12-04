import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../data/datasources/database_backup_restore.dart';
import '../../../localization/localization.dart';
import '../../../main.dart';

// Providers
import '../notlar/providers/not_providers.dart';
import '../durum/providers/durum_providers.dart';
import '../kategori/providers/kategori_providers.dart';
import '../kontrol_liste/providers/kontrol_liste_providers.dart';
import '../oncelik/providers/oncelik_providers.dart';
import '../hatirlatici/providers/hatirlatici_providers.dart';

// Screens
import 'package:notlarim/presentation/screen/oncelik/oncelik_listesi.dart';
import '../backup/backup_manager_screen.dart';
import '../durum/durum_listesi.dart';
import '../kategori/kategori_listesi.dart';
import '../kullanimklavuzu/kullanimklavuzu.dart';
import '../notlar/not_listesi.dart';
import '../kontrol_liste/kontrol_liste_listesi.dart';
import '../hatirlatici/hatirlatici_listesi.dart';
import '../login/loginpage.dart'; // ✅ Login sayfası import edildi

class AnaMenuMenuScreen extends ConsumerStatefulWidget {
  const AnaMenuMenuScreen({super.key});

  @override
  ConsumerState<AnaMenuMenuScreen> createState() => _AnaMenuMenuScreenState();
}

class _AnaMenuMenuScreenState extends ConsumerState<AnaMenuMenuScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    NotListesi(), // 0
    KategoriListesi(), // 1
    DurumListesi(), // 2
    OncelikListesi(), // 3
    KontrolListeListesi(), // 4
    HatirlaticiListesi(), // 5
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: [
          _buildMainMenu(loc),
          _buildLanguageMenu(loc),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      drawer: _buildDrawer(context),
      // ❌ floatingActionButton KALDIRILDI (Sayfalar kendi butonunu yönetecek)
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Text(
              loc.translate('app_title'),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _drawerItem(Icons.list, loc.translate('menu_notes'), 0),
          _drawerItem(Icons.category, loc.translate('menu_categories'), 1),
          _drawerItem(Icons.list_alt, loc.translate('menu_situations'), 2),
          _drawerItem(Icons.priority_high, loc.translate('menu_priorities'), 3),
          _drawerItem(Icons.checklist, loc.translate('menu_checklists'), 4),
          _drawerItem(Icons.alarm, loc.translate('general_reminder'), 5),
          const Divider(),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.grey.shade200,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
        _refreshPageData(index);
      },
    );
  }

  void _refreshPageData(int index) {
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

  PopupMenuButton<String> _buildMainMenu(AppLocalizations loc) {
    return PopupMenuButton<String>(
      onSelected: (String result) async {
        switch (result) {
          case 'backup':
            await _showBackupDialog();
            break;
          case 'restore':
            await _showRestoreDialog();
            break;
          case 'manage':
            await _openBackupManager();
            break;
          case 'version':
            await _showAppVersion();
            break;
          case 'about':
            _showAppInfo();
            break;
          case 'manual':
            _showUserManual(context);
            break;
          // ✅ ÇIKIŞ YAP İŞLEMİ
          case 'logout':
            _showLogoutConfirmation();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _popupItem(Icons.backup, loc.translate('database_getBackup'), 'backup'),
        _popupItem(
            Icons.restore, loc.translate('database_restoreBackup'), 'restore'),
        _popupItem(Icons.folder_open, loc.translate('database_manageBackups'),
            'manage'),
        const PopupMenuDivider(),

        // ✅ ÇIKIŞ YAP MENU ITEM
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              loc.translate('menu_logout'),
              style: const TextStyle(color: Colors.red),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),

        _popupItem(
            Icons.info, loc.translate('menu_versionInformation'), 'version'),
        _popupItem(Icons.help, loc.translate('menu_abouttheProgram'), 'about'),
        _popupItem(Icons.article, loc.translate('menu_userGuide'), 'manual'),
      ],
    );
  }

  PopupMenuButton<String> _buildLanguageMenu(AppLocalizations loc) {
    const langs = {
      'tr': 'menu_tr',
      'en': 'menu_en',
      'de': 'menu_de',
      'fr': 'menu_fr',
      'es': 'menu_es',
      'ar': 'menu_ar',
      'ru': 'menu_ru',
      'fa': 'menu_fa',
      'zh': 'menu_zh',
      'hi': 'menu_hi',
      'it': 'menu_it',
      'ja': 'menu_ja',
      'ko': 'menu_ko',
      'pt': 'menu_pt',
      'pl': 'menu_pl',
    };

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String value) {
        MyApp.setLocale(context, Locale(value));
      },
      itemBuilder: (BuildContext context) => langs.entries
          .map((e) => PopupMenuItem<String>(
                value: e.key,
                child: Text(loc.translate(e.value)),
              ))
          .toList(),
    );
  }

  PopupMenuItem<String> _popupItem(IconData icon, String title, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
      ),
    );
  }

  // ... Diğer mevcut fonksiyonlar (Backup, Version vb.) aynen duruyor ...

  void _showUserManual(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KullanimKilavuzuWidget()),
    );
  }

  Future<void> _showAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('menu_versionInformation')),
        content: Text(
          '${loc.translate('version')}: ${info.version}\n'
          '${loc.translate('buildNumber')}: ${info.buildNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('menu_abouttheProgram')),
        content: Text(loc.translate('program_description')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ ÇIKIŞ YAPMA FONKSİYONLARI
  // ---------------------------------------------------------------------------
  void _showLogoutConfirmation() {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.translate('menu_logout') ?? 'Çıkış Yap'),
          content: Text(loc.translate('logout_confirm_message') ??
              'Uygulamadan çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('menu_giveUp') ?? 'Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                _performLogout(); // Çıkış işlemini yap
              },
              child: Text(
                loc.translate('menu_yes') ?? 'Evet',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Tüm geçmiş sayfaları sil
    );
  }

  // ... Backup fonksiyonları aynen devam ediyor ...

  Future<void> _showBackupDialog() async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isButtonEnabled = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.translate('database_getBackup')),
          content: TextField(
            controller: controller,
            onChanged: (val) =>
                setState(() => isButtonEnabled = val.trim().length >= 3),
            decoration: InputDecoration(
              labelText: loc.translate('database_backupFileName'),
              helperText: loc.translate('database_getBackupMessage'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('menu_giveUp')),
            ),
            TextButton(
              onPressed: isButtonEnabled
                  ? () async {
                      Navigator.pop(context);
                      await _backupDatabase(controller.text.trim());
                    }
                  : null,
              child: Text(loc.translate('menu_yes')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRestoreDialog() async {
    final loc = AppLocalizations.of(context);
    final backups = await DatabaseBackupRestore.instance.listBackups();

    if (backups.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('database_noBackupFound')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedFile;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.translate('database_restoreBackup')),
          content: DropdownButtonFormField<String>(
            initialValue: selectedFile,
            hint: Text(loc.translate('database_selectBackupFile')),
            items: backups
                .map(
                  (f) => DropdownMenuItem<String>(
                    value: f.uri.pathSegments.last,
                    child: Text(f.uri.pathSegments.last),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedFile = val),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('menu_giveUp')),
            ),
            TextButton(
              onPressed: selectedFile != null
                  ? () async {
                      Navigator.pop(context);
                      await _restoreDatabase(selectedFile!);
                    }
                  : null,
              child: Text(loc.translate('menu_yes')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupDatabase(String fileName) async {
    final loc = AppLocalizations.of(context);
    try {
      final file = await DatabaseBackupRestore.instance
          .backupDatabase(fileName: '$fileName.db');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(file != null
              ? loc.translate('database_backupSuccessMessage')
              : loc.translate('database_backupErrorMessage')),
          backgroundColor: file != null ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.translate('database_backupErrorMessage')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreDatabase(String fileName) async {
    final loc = AppLocalizations.of(context);
    try {
      final success =
          await DatabaseBackupRestore.instance.restoreDatabase(fileName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? loc.translate('database_backupRestoreSuccessMessage')
              : loc.translate('database_backupRestoreErrorMessage')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _refreshPageData(0);
        _refreshPageData(1);
        _refreshPageData(2);
        _refreshPageData(3);
        _refreshPageData(4);
        _refreshPageData(5);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${loc.translate('database_backupRestoreErrorMessage')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openBackupManager() async {
    final selectedBackup = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BackupManagerScreen()),
    );
    if (selectedBackup != null) {
      await _restoreDatabase(selectedBackup);
    }
  }
}
