import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:fixit/core/utils/app_logger.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    AppLogger.log('Opening Drift database connection (Native)...');
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      AppLogger.log('Database file path: ${file.path}');
      return NativeDatabase.createInBackground(file);
    } catch (e) {
      AppLogger.error('Error opening Drift database', e);
      rethrow;
    }
  });
}
