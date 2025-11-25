import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Eklenen satır
import 'package:notlarim/localization/localization.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/config/app_config.dart';

class PermissionService {
  void permission(BuildContext context) async {
    if (AppConfig.androidSdkInt >= 30) {
      permissionAfter(context);
    } else {
      permissionBefore(context);
    }
  }

//Android 10 ve Öncesi için erişim izni
  void requestStoragePermissionVersion11Before(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // İzin istenmemiş veya kalıcı olarak reddedilmiş
      var result = await Permission.storage.request();
      if (result.isGranted) {
        // İzin verilmiş
        if (kDebugMode) {
          print(AppLocalizations.of(context).translate('permission_message1'));
        }
      } else {
        // İzin reddedilmiş
        if (kDebugMode) {
          print(AppLocalizations.of(context).translate('permission_message2'));
        }
        // Kullanıcıya izin reddetme nedenini açıklayın ve izin ayarlarına yönlendirin.
      }
    } else if (status.isGranted) {
      // İzin önceden verilmiş
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message3'));
      }
    }
  }

//Android 11 ve 12 için Dosya Erişim İzni
  void requestStoragePermissionVersion11And12(BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // İzin istenmemiş veya kalıcı olarak reddedilmiş
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        // İzin verilmiş
        if (kDebugMode) {
          print(AppLocalizations.of(context).translate('permission_message1'));
        }
      } else {
        // İzin reddedilmiş
        if (kDebugMode) {
          print(AppLocalizations.of(context).translate('permission_message2'));
        }
        // Kullanıcıya izin reddetme nedenini açıklayın ve izin ayarlarına yönlendirin.
      }
    } else if (status.isGranted) {
      // İzin önceden verilmiş
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message3'));
      }
    }
  }

  void permissionAfter(BuildContext context) async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message1'));
      }
    } else if (status.isDenied) {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message4'));
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('permission_message4')),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message5'));
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('permission_message5')),
        ),
      );
    }
  }

  void permissionBefore(BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;
    if (kDebugMode) {
      print(status);
    }

    if (status.isDenied) {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message6'));
      }
      await Permission.storage.request().then((value) {
        if (value.isGranted) {
          if (kDebugMode) {
            print(
                AppLocalizations.of(context).translate('permission_message7'));
          }
        } else {
          if (kDebugMode) {
            print(
                AppLocalizations.of(context).translate('permission_message8'));
          }
        }
      });
    } else if (status.isGranted) {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message7'));
      }
    } else {
      if (kDebugMode) {
        print(AppLocalizations.of(context).translate('permission_message8'));
      }
    }
  }
}
