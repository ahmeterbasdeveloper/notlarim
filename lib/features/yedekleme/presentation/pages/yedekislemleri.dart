import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';

import '../../../../core/database/database_backup_restore.dart';
import '../../../../core/database/database_helper.dart'; // ✅ Eklendi: DB yeniden başlatmak için

/// 💾 Uygulama içi yedekleme ve geri yükleme işlemleri
class YedekIslemleriWidget {
  final BuildContext context;

  YedekIslemleriWidget(this.context);

  // ---------------------------------------------------------------------------
  // 💾 Yedek Alma Dialogu
  // ---------------------------------------------------------------------------
  Future<void> showBackupDialog() async {
    final TextEditingController fileNameController = TextEditingController();
    bool isButtonEnabled = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                  AppLocalizations.of(context).translate('database_getBackup')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fileNameController,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled = value.trim().length >= 3;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('database_backupFileName'),
                      helperText: AppLocalizations.of(context)
                          .translate('database_getBackupMessage'),
                      helperStyle: const TextStyle(color: Colors.red),
                      hintText: AppLocalizations.of(context)
                          .translate('menu_enterFileName'),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                      AppLocalizations.of(context).translate('menu_giveUp')),
                ),
                TextButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          final fileName = fileNameController.text.trim();
                          Navigator.of(context).pop();
                          await _backupDatabase(fileName);
                        }
                      : null,
                  child:
                      Text(AppLocalizations.of(context).translate('menu_yes')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ♻️ Geri Yükleme Dialogu
  // ---------------------------------------------------------------------------
  Future<void> showRestoreDialog() async {
    final backups = await DatabaseBackupRestore.instance.listBackups();

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('database_noBackupFound')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedFileName;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)
                  .translate('database_restoreBackup')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedFileName,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('database_backupFile'),
                    ),
                    items: backups
                        .map(
                          (f) => DropdownMenuItem<String>(
                            value: f.uri.pathSegments.last,
                            child: Text(f.uri.pathSegments.last),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedFileName = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                      AppLocalizations.of(context).translate('menu_giveUp')),
                ),
                TextButton(
                  onPressed: selectedFileName != null
                      ? () async {
                          Navigator.of(context).pop();
                          await _restoreDatabase(selectedFileName!);
                        }
                      : null,
                  child:
                      Text(AppLocalizations.of(context).translate('menu_yes')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 Yedekleme İşlemi
  // ---------------------------------------------------------------------------
  Future<void> _backupDatabase(String fileName) async {
    try {
      final backupFile = await DatabaseBackupRestore.instance
          .backupDatabase(fileName: '$fileName.db');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backupFile != null
                ? AppLocalizations.of(context)
                    .translate('database_backupSuccessMessage')
                : AppLocalizations.of(context)
                    .translate('database_backupErrorMessage')),
            backgroundColor: backupFile != null ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).translate('database_backupErrorMessage')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Geri Yükleme İşlemi (Yenilenmiş)
  // ---------------------------------------------------------------------------
  Future<void> _restoreDatabase(String fileName) async {
    try {
      final success =
          await DatabaseBackupRestore.instance.restoreDatabase(fileName);

      if (!context.mounted) return;

      if (success) {
        // ✅ Veritabanı bağlantısını yeniden aç
        await DatabaseHelper.instance.reopen();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('database_backupRestoreSuccessMessage')),
            backgroundColor: Colors.green,
          ),
        );

        // 🔁 İstersen mevcut sayfayı anında yenile (örnek)
        // ignore: use_build_context_synchronously
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('database_backupRestoreErrorMessage')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).translate('database_backupRestoreErrorMessage')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
