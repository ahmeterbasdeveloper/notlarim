import 'package:flutter/material.dart';
import 'package:notlarim/presentation/screen/notlar/not_add_edit.dart';
import 'package:notlarim/presentation/screen/oncelik/oncelik_listesi.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../data/datasources/database_backup_restore.dart';
import '../../../localization/localization.dart';
import '../../../main.dart';

// Screens
import '../backup/backup_manager_screen.dart';
import '../durum/durum_listesi.dart';
import '../kategori/kategori_listesi.dart';
import '../kullanimklavuzu/kullanimklavuzu.dart';
import '../notlar/not_listesi.dart';
import '../kontrol_liste/kontrol_liste_listesi.dart';

// ✅ EKLENDİ: Abstract Interface
import '../../../core/abstract_db_service.dart';

// UseCases & Repositories
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/not_repository_impl.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../domain/usecases/not/get_all_not.dart';
import '../../../domain/usecases/not/create_not.dart';
import '../../../domain/usecases/not/update_not.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';

class AnaMenuMenuScreen extends StatefulWidget {
  const AnaMenuMenuScreen({super.key});

  @override
  State<AnaMenuMenuScreen> createState() => _AnaMenuMenuScreenState();
}

class _AnaMenuMenuScreenState extends State<AnaMenuMenuScreen> {
  late Widget _currentWidget;
  int _selectedIndex = 0;

  // UseCases
  late final GetAllNot _getAllNotUseCase;
  late final CreateNot _createNotUseCase;
  late final UpdateNot _updateNotUseCase;
  late final GetAllKategori _getAllKategoriUseCase;
  late final GetAllOncelik _getAllOncelikUseCase;

  @override
  void initState() {
    super.initState();
    _setupUseCases();
    // İlk açılışta Not Listesini yükle
    _currentWidget = const NotListesi();
  }

  void _setupUseCases() {
    // ✅ DÜZELTİLDİ: Singleton instance'ı 'AbstractDBService' olarak alıyoruz.
    // Repository'ler constructor'larında bu tipi bekliyor.
    final AbstractDBService dbService = DatabaseHelper.instance;

    // Repository'lere 'dbService' gönderiyoruz
    final kategoriRepo = KategoriRepositoryImpl(dbService);
    final oncelikRepo = OncelikRepositoryImpl(dbService);

    final notRepo = NotRepositoryImpl(
      dbService,
      kategoriRepository: kategoriRepo,
      oncelikRepository: oncelikRepo,
    );

    // UseCase'leri oluşturuyoruz
    _getAllNotUseCase = GetAllNot(notRepo);
    _createNotUseCase = CreateNot(notRepo);
    _updateNotUseCase = UpdateNot(notRepo);
    _getAllKategoriUseCase = GetAllKategori(kategoriRepo);
    _getAllOncelikUseCase = GetAllOncelik(oncelikRepo);
  }

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
      // body: _currentWidget, // Doğrudan widget kullanımı yerine Key ile yenilemeyi garanti edebiliriz (opsiyonel)
      body: _currentWidget,
      drawer: _buildDrawer(context),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 78, 18, 92),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotAddEdit(
                      createNotUseCase: _createNotUseCase,
                      updateNotUseCase: _updateNotUseCase,
                      getAllKategoriUseCase: _getAllKategoriUseCase,
                      getAllOncelikUseCase: _getAllOncelikUseCase,
                    ),
                  ),
                );
                _refreshCurrentWidget();
              },
            )
          : null,
    );
  }

  // Drawer
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
          _drawerItem(
              Icons.list, loc.translate('menu_notes'), const NotListesi(), 0),
          _drawerItem(Icons.category, loc.translate('menu_categories'),
              const KategoriListesi(), 1),
          _drawerItem(Icons.list_alt, loc.translate('menu_situations'),
              const DurumListesi(), 2),
          _drawerItem(Icons.priority_high, loc.translate('menu_priorities'),
              const OncelikListesi(), 3),
          _drawerItem(Icons.checklist, loc.translate('menu_checklists'),
              const KontrolListeListesi(), 4),
          const Divider(),
        ],
      ),
    );
  }

  ListTile _drawerItem(
      IconData icon, String title, Widget page, int selectedIndex) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _loadWidget(page);
          _selectedIndex = selectedIndex;
        });
      },
    );
  }

  // Popup Menüler
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
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _popupItem(Icons.backup, loc.translate('database_getBackup'), 'backup'),
        _popupItem(
            Icons.restore, loc.translate('database_restoreBackup'), 'restore'),
        _popupItem(Icons.folder_open, loc.translate('database_manageBackups'),
            'manage'),
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
          .map(
            (e) => PopupMenuItem<String>(
              value: e.key,
              child: Text(loc.translate(e.value)),
            ),
          )
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

  // Widget yükleme (UniqueKey ekleyerek sayfanın sıfırdan oluşmasını sağlıyoruz)
  void _loadWidget(Widget widget) {
    _currentWidget = widget;
    // Eğer widget stateful ise ve key alıyorsa, yeni bir key vermek rebuild tetikler.
    // Ancak _currentWidget değişimini setState içinde yapmak gerekir (aşağıda yapılıyor).
  }

  // Kullanım Kılavuzu
  void _showUserManual(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KullanimKilavuzuWidget()),
    );
  }

  // Versiyon Bilgisi
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

  // Program Bilgisi
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
  // BACKUP & RESTORE
  // ---------------------------------------------------------------------------
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

      if (success) _refreshCurrentWidget();
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

  void _refreshCurrentWidget() {
    setState(() {
      // UniqueKey kullanarak widget'ın tamamen yeniden oluşturulmasını (rebuild) sağlıyoruz.
      // Bu sayede liste sayfasındaki initState tekrar çalışır ve veriler yeniden çekilir.
      switch (_selectedIndex) {
        case 0:
          _currentWidget = NotListesi(key: UniqueKey());
          break;
        case 1:
          _currentWidget = KategoriListesi(key: UniqueKey());
          break;
        case 2:
          _currentWidget = DurumListesi(key: UniqueKey());
          break;
        case 3:
          _currentWidget = OncelikListesi(key: UniqueKey());
          break;
        case 4:
          _currentWidget = KontrolListeListesi(key: UniqueKey());
          break;
        default:
          _currentWidget = NotListesi(key: UniqueKey());
      }
    });
  }
}
