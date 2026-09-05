import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:fixit/core/utils/app_logger.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    AppLogger.log('Opening Drift database connection (Web/WASM)...');
    try {
      final result = await WasmDatabase.open(
        databaseName: 'db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    } catch (e) {
      AppLogger.error('Error opening Drift database on Web', e);
      rethrow;
    }
  });
}
