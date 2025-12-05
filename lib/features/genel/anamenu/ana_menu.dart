import 'dart:io'; // Yedek listeleme için gerekli
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kullanicilar/presentation/pages/loginpage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/database/database_backup_restore.dart'; // Listeleme için
import '../../../core/localization/localization.dart';
import '../../../main.dart';

// UI Components
import 'widgets/ana_menu_drawer.dart';

// ✅ Controller Provider Importu (Yolunu projenize göre kontrol edin)
import 'providers/ana_menu_controller.dart';

// Pages
import '../../genel/hakkinda/hakkinda.dart'; // Hakkında Widget'ı
import '../../genel/kullanimklavuzu/kullanimklavuzu.dart'; // Kılavuz Widget'ı
import '../../notlar/presentation/pages/not_listesi.dart';
import '../../kategoriler/presentation/pages/kategori_listesi.dart';
import '../../durumlar/presentation/pages/durum_listesi.dart';
import '../../oncelik/presentation/pages/oncelik_listesi.dart';
import '../../kontrol_listesi/presentation/pages/kontrol_liste_listesi.dart';
import '../../hatirlaticilar/presentation/pages/hatirlatici_listesi.dart';
import '../../yedekleme/presentation/pages/backup_manager_screen.dart'; // Yedek yöneticisi

class AnaMenuMenuScreen extends ConsumerStatefulWidget {
  const AnaMenuMenuScreen({super.key});

  @override
  ConsumerState<AnaMenuMenuScreen> createState() => _AnaMenuMenuScreenState();
}

class _AnaMenuMenuScreenState extends ConsumerState<AnaMenuMenuScreen> {
  // Mixin kaldırıldı, logic artık Controller ve buradaki UI metodlarında.
  int _selectedIndex = 0;

  // Giriş yapan kullanıcı (Normalde Login'den parametre gelmeli veya UserProvider'dan okunmalı)
  final String _currentUserName = "admin";

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

    // 1. STATE DINLEME: Controller'dan gelen mesajları dinle
    ref.listen(anaMenuControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
        // Mesajı temizle
        ref.read(anaMenuControllerProvider.notifier).clearMessages();
      }

      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(anaMenuControllerProvider.notifier).clearMessages();
      }
    });

    // 2. Loading Durumu
    final isLoading = ref.watch(anaMenuControllerProvider).isLoading;

    return Stack(
      children: [
        Scaffold(
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
          drawer: AnaMenuDrawer(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            // Logic metodlarını bağlıyoruz
            onLogoutTap: _showLogoutConfirmation,
            onChangePasswordTap: _showChangePasswordFlow,
            onChangeSecurityCodeTap: _showChangeSecurityCodeFlow,
          ),
        ),

        // 3. Loading Göstergesi (Tüm ekranı kaplayan)
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  // --- APP BAR MENÜLERİ ---

  PopupMenuButton<String> _buildMainMenu(AppLocalizations loc) {
    return PopupMenuButton<String>(
      onSelected: (String result) async {
        switch (result) {
          case 'backup':
            await _showSecurityCheckDialog(
                onSuccess: () => _showBackupDialog());
            break;
          case 'restore':
            await _showSecurityCheckDialog(
                onSuccess: () => _showRestoreDialog());
            break;
          case 'manage':
            await _showSecurityCheckDialog(
                onSuccess: () => _openBackupManager());
            break;
          case 'factory_reset':
            await _showSecurityCheckDialog(
                onSuccess: () => _showFactoryResetConfirmation());
            break;
          case 'version':
            await _showAppVersion();
            break;
          case 'about':
            _showAppInfo();
            break;
          case 'manual':
            _showUserManual();
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
        PopupMenuItem<String>(
          value: 'factory_reset',
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.orange),
            title: Text(
              loc.translate('menu_factoryReset') ?? 'Fabrika Ayarlarına Dön',
              style: const TextStyle(color: Colors.orange),
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

  // ===========================================================================
  // 🧩 UI LOGIC METODLARI (Eskiden Mixin'de olanlar)
  // ===========================================================================

  // 1. Çıkış Yap
  void _showLogoutConfirmation() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.translate('menu_logout') ?? 'Çıkış Yap'),
          content:
              Text(loc.translate('logout_confirm_message') ?? 'Emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('menu_giveUp') ?? 'Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(loc.translate('menu_yes') ?? 'Evet',
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 2. Güvenlik Kontrolü (Yedekleme vb. öncesi)
  Future<void> _showSecurityCheckDialog(
      {required VoidCallback onSuccess}) async {
    final codeController = TextEditingController();
    final loc = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Güvenlik Kontrolü"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("İşlem için Güvenlik Kodunu giriniz."),
            const SizedBox(height: 10),
            TextField(
              controller: codeController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Güvenlik Kodu",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.translate('menu_giveUp') ?? 'Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;

              // Logic Controller üzerinden kontrol
              final isValid = await ref
                  .read(anaMenuControllerProvider.notifier)
                  .verifySecurityCode(_currentUserName, code);

              if (isValid && mounted) {
                Navigator.pop(ctx);
                onSuccess();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Hatalı Güvenlik Kodu!"),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text("Doğrula"),
          ),
        ],
      ),
    );
  }

  // 3. Yedek Alma Penceresi
  Future<void> _showBackupDialog() async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isButtonEnabled = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: Text(loc.translate('database_getBackup')),
          content: TextField(
            controller: controller,
            onChanged: (val) =>
                setStateBuilder(() => isButtonEnabled = val.trim().length >= 3),
            decoration: InputDecoration(
              labelText: loc.translate('database_backupFileName'),
              helperText: loc.translate('database_getBackupMessage'),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.translate('menu_giveUp'))),
            TextButton(
              onPressed: isButtonEnabled
                  ? () async {
                      Navigator.pop(context);
                      // Logic Controller çağrısı
                      await ref
                          .read(anaMenuControllerProvider.notifier)
                          .backupDatabase(controller.text.trim());
                    }
                  : null,
              child: Text(loc.translate('menu_yes')),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Geri Yükleme Penceresi
  Future<void> _showRestoreDialog() async {
    final loc = AppLocalizations.of(context);
    // Yedekleri listeleme işlemi basit dosya okuma olduğu için burada yapabiliriz
    // veya Controller'dan bir Future döndürebiliriz.
    final backups = await DatabaseBackupRestore.instance.listBackups();

    if (backups.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.translate('database_noBackupFound')),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    String? selectedFile;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: Text(loc.translate('database_restoreBackup')),
          content: DropdownButtonFormField<String>(
            value: selectedFile,
            hint: Text(loc.translate('database_selectBackupFile')),
            items: backups
                .map((f) => DropdownMenuItem(
                    value: f.uri.pathSegments.last,
                    child: Text(f.uri.pathSegments.last)))
                .toList(),
            onChanged: (val) => setStateBuilder(() => selectedFile = val),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.translate('menu_giveUp'))),
            TextButton(
              onPressed: selectedFile != null
                  ? () async {
                      Navigator.pop(context);
                      // Logic Controller çağrısı
                      await ref
                          .read(anaMenuControllerProvider.notifier)
                          .restoreDatabase(selectedFile!);
                    }
                  : null,
              child: Text(loc.translate('menu_yes')),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Yedek Yönetimi Ekranı
  Future<void> _openBackupManager() async {
    final selectedBackup = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BackupManagerScreen()),
    );
    if (selectedBackup != null) {
      await ref
          .read(anaMenuControllerProvider.notifier)
          .restoreDatabase(selectedBackup);
    }
  }

  // 6. Fabrika Ayarları Onayı
  Future<void> _showFactoryResetConfirmation() async {
    final loc = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(loc.translate('menu_factoryReset') ?? 'Sıfırla',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
            loc.translate('factory_reset_warning') ?? 'Tüm veriler silinecek!'),
        actions: [
          TextButton(
            child: Text(loc.translate('menu_giveUp') ?? 'Vazgeç'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.translate('menu_yes') ?? 'Evet',
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(ctx);
              // Logic Controller çağrısı
              ref.read(anaMenuControllerProvider.notifier).factoryReset();
            },
          ),
        ],
      ),
    );
  }

  // 7. Şifre Değiştirme Akışı
  Future<void> _showChangePasswordFlow() async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Şifre Değiştir"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Eski Şifre"),
                  validator: (v) => v!.isEmpty ? "Gerekli" : null,
                ),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Yeni Şifre"),
                  validator: (v) =>
                      (v != null && v.length < 4) ? "En az 4 karakter" : null,
                ),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: "Yeni Şifre (Tekrar)"),
                  validator: (v) =>
                      v != newPassController.text ? "Uyuşmuyor" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // 1. Controller ile eski şifre doğrulama
                final isVerified = await ref
                    .read(anaMenuControllerProvider.notifier)
                    .verifyUserCredentials(
                        _currentUserName, oldPassController.text.trim());

                if (isVerified && mounted) {
                  Navigator.pop(ctx);
                  // 2. Controller ile güncelleme
                  await ref
                      .read(anaMenuControllerProvider.notifier)
                      .updatePassword(
                          _currentUserName, newPassController.text.trim());
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Eski şifre hatalı"),
                      backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  // 8. Güvenlik Kodu Değiştirme Akışı
  Future<void> _showChangeSecurityCodeFlow() async {
    final passController = TextEditingController();
    final codeController = TextEditingController(); // Mevcut kod
    final newCodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Basitleştirilmiş tek aşamalı dialog
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Güvenlik Kodu Değiştir"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Değişiklik için mevcut şifrenizi ve eski kodunuzu girin."),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Mevcut Şifre"),
                  validator: (v) => v!.isEmpty ? "Gerekli" : null,
                ),
                TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: "Eski Güvenlik Kodu"),
                  validator: (v) => v!.isEmpty ? "Gerekli" : null,
                ),
                const Divider(),
                TextFormField(
                  controller: newCodeController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: "Yeni Güvenlik Kodu"),
                  validator: (v) =>
                      (v != null && v.length < 4) ? "En az 4 hane" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final notifier = ref.read(anaMenuControllerProvider.notifier);

                // 1. Şifre Doğrulama
                final isPassCorrect = await notifier.verifyUserCredentials(
                    _currentUserName, passController.text.trim());

                // 2. Eski Kod Doğrulama
                final isCodeCorrect = await notifier.verifySecurityCode(
                    _currentUserName, codeController.text.trim());

                if (isPassCorrect && isCodeCorrect && mounted) {
                  Navigator.pop(ctx);
                  // 3. Güncelleme
                  await notifier.updateSecurityCode(
                      _currentUserName, newCodeController.text.trim());
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Bilgiler doğrulanamadı!"),
                      backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  // 9. Versiyon Bilgisi
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
              child: Text(loc.translate('close') ?? 'Kapat')),
        ],
      ),
    );
  }

  // 10. Hakkında ve Kılavuz (Sayfa Yönlendirmeleri)
  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (_) =>
          const ProgramHakkindaWidget(), // hakkinda.dart içindeki widget
    );
  }

  void _showUserManual() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const KullanimKilavuzuWidget()));
  }
}
