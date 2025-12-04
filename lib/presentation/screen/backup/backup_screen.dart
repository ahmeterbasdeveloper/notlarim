import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/datasources/database_backup_restore.dart';
import '../../../data/datasources/database_helper.dart'; // ✅ Eklendi: DB bağlantısını yeniden açmak için
import '../../../localization/localization.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<FileSystemEntity> _backups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  /// 📂 Yedekleri listele
  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    final backups = await DatabaseBackupRestore.instance.listBackups();
    setState(() {
      _backups = backups.reversed.toList(); // En yeni üstte
      _isLoading = false;
    });
  }

  /// 💾 Yeni yedek oluştur
  Future<void> _createBackup(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isEnabled = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(loc.translate('database_getBackup')),
              content: TextField(
                controller: controller,
                onChanged: (val) =>
                    setState(() => isEnabled = val.trim().length >= 3),
                decoration: InputDecoration(
                  labelText: loc.translate('database_backupFileName'),
                  helperText: loc.translate('database_getBackupMessage'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(loc.translate('menu_giveUp')),
                ),
                TextButton(
                  onPressed: isEnabled
                      ? () async {
                          final name = controller.text.trim();
                          Navigator.pop(ctx);
                          final file = await DatabaseBackupRestore.instance
                              .backupDatabase(fileName: '$name.db');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(file != null
                                  ? loc.translate(
                                      'database_backupSuccessMessage')
                                  : loc.translate(
                                      'database_backupErrorMessage')),
                              backgroundColor:
                                  file != null ? Colors.green : Colors.red,
                            ));
                          }
                          _loadBackups();
                        }
                      : null,
                  child: Text(loc.translate('menu_yes')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ♻️ Yedekten geri yükleme
  Future<void> _restoreBackup(BuildContext context, String fileName) async {
    final loc = AppLocalizations.of(context);
    bool confirm = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('database_restoreBackup')),
        content: Text(
          loc.translate('database_restoreConfirmMessage') ??
              "Seçilen yedekten geri yükleme yapmak istediğinizden emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('menu_giveUp')),
          ),
          TextButton(
            onPressed: () {
              confirm = true;
              Navigator.pop(context);
            },
            child: Text(loc.translate('menu_yes')),
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      final success =
          await DatabaseBackupRestore.instance.restoreDatabase(fileName);

      if (!context.mounted) return;

      if (success) {
        // ✅ DB bağlantısını yeniden aç
        await DatabaseHelper.instance.reopen();

        // 🔁 Üst ekrana bilgi döndür (örneğin Ana Menü yenilensin)
        if (Navigator.canPop(context)) {
          Navigator.pop(context, fileName);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.translate('database_backupRestoreSuccessMessage')),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.translate('database_backupRestoreErrorMessage')),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('${loc.translate('database_backupRestoreErrorMessage')}: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// 🗑️ Yedek silme
  Future<void> _deleteBackup(BuildContext context, String fileName) async {
    final loc = AppLocalizations.of(context);
    bool confirm = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('menu_delete')),
        content: Text(
          loc.translate('database_deleteConfirmMessage') ??
              "Bu yedek dosyasını silmek istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('menu_giveUp')),
          ),
          TextButton(
            onPressed: () {
              confirm = true;
              Navigator.pop(context);
            },
            child: Text(loc.translate('menu_yes')),
          ),
        ],
      ),
    );

    if (confirm) {
      await DatabaseBackupRestore.instance.deleteBackup(fileName);
      await _loadBackups();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.translate('database_backupDeleted')),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  /// 📤 Yedek paylaşımı
  Future<void> _shareBackup(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: '📦 Notlarım Yedeği');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('database_manageBackups')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: loc.translate('database_getBackup'),
            onPressed: () => _createBackup(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('general_refresh'),
            onPressed: _loadBackups,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _backups.isEmpty
              ? Center(
                  child: Text(loc.translate('database_noBackupFound')),
                )
              : ListView.builder(
                  itemCount: _backups.length,
                  itemBuilder: (context, index) {
                    final file = _backups[index];
                    final name = file.uri.pathSegments.last;
                    final modified = file.statSync().modified;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(name),
                        subtitle: Text(
                          '${loc.translate('database_backupDate')}: '
                          '${modified.toString().substring(0, 19)}',
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'restore') {
                              _restoreBackup(context, name);
                            } else if (value == 'delete') {
                              _deleteBackup(context, name);
                            } else if (value == 'share') {
                              _shareBackup(file.path);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'restore',
                              child: Row(
                                children: [
                                  const Icon(Icons.restore, size: 18),
                                  const SizedBox(width: 8),
                                  Text(loc.translate('database_restoreBackup')),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: const [
                                  Icon(Icons.share, size: 18),
                                  SizedBox(width: 8),
                                  Text('Paylaş'), // sabit string
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 18),
                                  const SizedBox(width: 8),
                                  Text(loc.translate('menu_delete')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
