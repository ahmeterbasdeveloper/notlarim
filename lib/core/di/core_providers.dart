import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../abstract_db_service.dart';
import '../../data/datasources/database_helper.dart';

// =============================================================================
// DATABASE PROVIDER
// =============================================================================
final dbServiceProvider = Provider<AbstractDBService>((ref) {
  return DatabaseHelper.instance;
});
