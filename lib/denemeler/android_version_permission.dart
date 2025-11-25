// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class AndroidVersionInfo {
  static bool permissionStatus = false;
  static String androidVersion = "";
  static int androidSdk = 0;
  static String manufacturer = "";
  static String model = "";

  static Future<void> getAndroidVersion() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      androidVersion = androidInfo.version.release;
      androidSdk = androidInfo.version.sdkInt;

      if (kDebugMode) {
        print("Android $androidVersion SDK $androidSdk");
        print("Android Versiyon ve SDK Bilgisi Alındı");
      }
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;

      if (kDebugMode) {
        print('$systemName $version, $name $model');
      }
    }
  }

  static Future<void> pathlar() async {
    // ignore: no_leading_underscores_for_local_identifiers
    Directory _getApplicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    String _getApplicationDocumentsDirectory1 =
        (await getApplicationDocumentsDirectory()).path;

    // ignore: no_leading_underscores_for_local_identifiers
    Directory _getTemporaryDirectory = await getTemporaryDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    String _getTemporaryDirectory1 = (await getTemporaryDirectory()).path;

    // ignore: no_leading_underscores_for_local_identifiers
    Directory _getDatabasesPath = (await getDatabasesPath()) as Directory;
    // ignore: no_leading_underscores_for_local_identifiers
    String _getDatabasesPath1 = await getDatabasesPath();

    // ignore: no_leading_underscores_for_local_identifiers
    Directory? _getExternalStorageDirectory =
        await getExternalStorageDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    String _getExternalStorageDirectory1 =
        (await getExternalStorageDirectory()) as String;

    // ignore: no_leading_underscores_for_local_identifiers
    Directory _getApplicationCacheDirectory =
        await getApplicationCacheDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    String _getApplicationCacheDirectory1 =
        (await getApplicationCacheDirectory()) as String;

    // ignore: no_leading_underscores_for_local_identifiers
    Directory? _getDownloadsDirectory = await getDownloadsDirectory();
    // ignore: no_leading_underscores_for_local_identifiers
    String _getDownloadsDirectory1 = (await getDownloadsDirectory()) as String;
  }

  static Future<bool> getPermissions() async {
    if (Platform.isAndroid) {
      if (androidSdk >= 30) {
        var storageStatus = await Permission.manageExternalStorage.status;
        if (storageStatus != PermissionStatus.granted) {
          var result = await Permission.manageExternalStorage.request();
          if (result == PermissionStatus.granted) {
            permissionStatus = true;
            return true;
          }
        } else {
          // İzin zaten verilmişse doğrudan true döndürülebilir.
          permissionStatus = true;
          return true;
        }
      } else {
        var storageStatus = await Permission.storage.status;
        if (storageStatus != PermissionStatus.granted) {
          var result = await Permission.storage.request();
          if (result == PermissionStatus.granted) {
            permissionStatus = true;
            return true;
          }
        } else {
          // İzin zaten verilmişse doğrudan true döndürülebilir.
          permissionStatus = true;
          return true;
        }
      }
    } else if (Platform.isIOS) {
      // iOS için her zaman izin verilmiş kabul edilir.
      permissionStatus = true;
      return true;
    } else {
      // Platform Android veya iOS değilse varsayılan olarak izin verilmiş kabul edilir.
      permissionStatus = true;
      return true;
    }
    // Platform Android veya iOS değilse varsayılan olarak izin verilmiş kabul edilir.
    permissionStatus = true;
    return true;
  }
}
