import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().nullable().unique()();
  TextColumn get username => text()();
  TextColumn get avatarUrl => text().nullable()();
  IntColumn get totalGamesPlayed => integer().withDefault(const Constant(0))();
  IntColumn get highscore => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Progressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerSupabaseId => text().nullable().unique()();
  IntColumn get currentLevel => integer().withDefault(const Constant(1))();
  TextColumn get unlockedWorlds => text().map(const WorldListConverter())();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class WorldListConverter extends TypeConverter<List<String>, String> {
  const WorldListConverter();
  @override
  List<String> fromSql(String fromDb) {
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(tables: [Players, Progressions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
