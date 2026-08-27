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
  
  // New Inventory Fields
  IntColumn get lives => integer().withDefault(const Constant(5))();
  IntColumn get hints => integer().withDefault(const Constant(10))();
  DateTimeColumn get lastLifeLostAt => dateTime().nullable()();
  
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Progressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerSupabaseId => text().nullable().unique()();
  IntColumn get currentLevel => integer().withDefault(const Constant(1))();
  TextColumn get unlockedWorlds => text().map(const WorldListConverter())();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class LevelCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerSupabaseId => text()();
  TextColumn get worldId => text()();
  IntColumn get levelNumber => integer()();
  IntColumn get completionTimeSeconds => integer()();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playerSupabaseId, worldId, levelNumber}
  ];
}

class GlobalLevels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get worldId => text()();
  IntColumn get levelNumber => integer()();
  
  // Storing structure as JSON strings
  TextColumn get hintsJson => text()();
  TextColumn get wallsJson => text()();
  TextColumn get solutionJson => text()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {worldId, levelNumber}
  ];
}

class WorldListConverter extends TypeConverter<List<String>, String> {
  const WorldListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(tables: [Players, Progressions, LevelCompletions, GlobalLevels])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Increment version

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add new columns to Players
          await m.addColumn(players, players.lives);
          await m.addColumn(players, players.hints);
          await m.addColumn(players, players.lastLifeLostAt);
          
          // Create new tables
          await m.createTable(levelCompletions);
          await m.createTable(globalLevels);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
