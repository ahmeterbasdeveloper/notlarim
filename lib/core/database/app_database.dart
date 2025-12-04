import 'package:sqflite/sqflite.dart';
import 'package:notlarim/core/database/database_helper.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  AppDatabase._init();

  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  Future<void> close() async => await DatabaseHelper.instance.close();
}
