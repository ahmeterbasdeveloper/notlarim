import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/datasources/database_backup_restore.dart';
import 'package:notlarim/localization/localization.dart';

class BackupManagerScreen extends StatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  State<BackupManagerScreen> createState() => _BackupManagerScreenState();
}

class _BackupManagerScreenState extends State<BackupManagerScreen> {
  List<FileSystemEntity> backups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  /// 📂 Yedekleri listele
  Future<void> _loadBackups() async {
    final list = await DatabaseBackupRestore.instance.listBackups();
    list.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (!mounted) return;
    setState(() {
      backups = list;
      isLoading = false;
    });
  }

  /// 🗑️ Yedek silme
  Future<void> _deleteBackup(String fileName) async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('menu_deleteBackupConfirmTitle') ?? 'Yedek Sil'),
        content: Text(
          '${loc.translate('menu_deleteBackupConfirmMessage') ?? 'Bu yedeği silmek istiyor musunuz?'}\n\n$fileName',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('menu_giveUp')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.translate('menu_yes')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DatabaseBackupRestore.instance.deleteBackup(fileName);
    await _loadBackups();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.translate('database_backupDeleted')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// 📥 Harici .db dosyası seçip geri yükleme
  Future<void> _importExternalBackup() async {
    final loc = AppLocalizations.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);

      // ✅ Dosyayı uygulamanın backup klasörüne kopyala
      final newPath = await DatabaseBackupRestore.instance.copyToBackupFolder(file);
      final newFileName = newPath.split('/').last;

      // ✅ restoreDatabase fonksiyonu artık backup klasöründen çalışacak
      final success = await DatabaseBackupRestore.instance.restoreDatabase(newFileName);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? loc.translate('database_backupRestoreSuccessMessage')
              : loc.translate('database_backupRestoreErrorMessage')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      await _loadBackups();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yedek yükleme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('database_manageBackups')),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            tooltip: loc.translate('menu_selectFile'),
            onPressed: _importExternalBackup,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('general_refresh'),
            onPressed: _loadBackups,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : backups.isEmpty
              ? Center(child: Text(loc.translate('database_noBackupFound')))
              : ListView.builder(
                  itemCount: backups.length,
                  itemBuilder: (context, index) {
                    final file = backups[index];
                    final name = file.uri.pathSegments.last;
                    final modified = file.statSync().modified;

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.storage),
                        title: Text(name),
                        subtitle: Text(
                          '${loc.translate('database_backupDate') ?? 'Yedek Tarihi'}: ${modified.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () async {
                                await DatabaseBackupRestore.shareBackupFile(name);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBackup(name),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (!mounted) return;
                          final restore = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(loc.translate('database_restoreBackup')),
                              content: Text(
                                '${loc.translate('database_restoreConfirmMessage') ?? 'Bu yedeği geri yüklemek istiyor musunuz?'}\n\n$name',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(loc.translate('menu_giveUp')),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(loc.translate('menu_yes')),
                                ),
                              ],
                            ),
                          );

                          if (restore == true && mounted) {
                            Navigator.pop(context, name);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
