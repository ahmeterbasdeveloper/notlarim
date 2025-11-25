import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConfig {
  AppConfig._();

  static int androidSdkInt = 0;
  static int pathDbDirectoryTip =
      2; //eğer 1 (bir) ise getApplicationDocumentsDirectory, 2 (iki) ise getDatabasesPath olacak

  static const databaseName = "notlar.db";
  static const databaseVersion = 1;

  static const headerColorList = [
    Color.fromARGB(255, 224, 36, 45),
    Color.fromARGB(255, 153, 33, 37),
    Color.fromARGB(255, 189, 51, 55),
    Color.fromARGB(255, 218, 77, 82),
    Color.fromARGB(255, 231, 85, 90),
    Color.fromARGB(255, 245, 133, 137),
  ];

  static const bodyColorList = [
    Color.fromARGB(255, 248, 52, 59),
    Color.fromARGB(255, 228, 48, 54),
    Color.fromARGB(255, 201, 44, 49),
    Color.fromARGB(255, 177, 39, 44),
    Color.fromARGB(255, 153, 33, 37),
    Color.fromARGB(255, 119, 25, 29),
  ];

  static const footerColorList = [
    Color.fromARGB(255, 248, 52, 59),
    Color.fromARGB(255, 228, 48, 54),
    Color.fromARGB(255, 201, 44, 49),
    Color.fromARGB(255, 177, 39, 44),
    Color.fromARGB(255, 153, 33, 37),
    Color.fromARGB(255, 119, 25, 29),
  ];

  static const headerColor = Color.fromARGB(255, 245, 232, 233);
  static const bodyColor = Color.fromARGB(255, 235, 135, 135);
  static const footerColor = Color.fromARGB(255, 245, 232, 233);

  static const splashColor = Color.fromARGB(255, 221, 212, 212);
  static const backroundColor = Color.fromARGB(255, 235, 229, 229);

  static DateFormat dateFormat = DateFormat('dd.MM.yyyy');
}
