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
  IntColumn get puzzlePieces => integer().withDefault(const Constant(50))();
  IntColumn get itemPlusTime => integer().withDefault(const Constant(5))();
  IntColumn get itemMoreNumbers => integer().withDefault(const Constant(5))();
  IntColumn get itemRevealPath => integer().withDefault(const Constant(5))();
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

class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerId => text()(); 
  TextColumn get friendId => text()();
  TextColumn get friendUsername => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playerId, friendId}
  ];
}

class FriendRequests extends Table {
  TextColumn get id => text()(); // Supabase UUID
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get senderUsername => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyChallenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerSupabaseId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  BoolColumn get isDailyLevelCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get dailyLevelTime => integer().withDefault(const Constant(0))(); // Time for single daily level
  IntColumn get seriesCurrentLevel => integer().withDefault(const Constant(0))(); // 0 to 3
  IntColumn get seriesAccumulatedTime => integer().withDefault(const Constant(0))();
  BoolColumn get isSeriesCompleted => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playerSupabaseId, date}
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

@DriftDatabase(tables: [Players, Progressions, LevelCompletions, GlobalLevels, Friends, FriendRequests, DailyChallenges])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Increment version

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(players, players.lives);
          await m.createTable(levelCompletions);
          await m.createTable(globalLevels);
        }
        if (from < 3) {
          await m.createTable(friends);
          await m.createTable(friendRequests);
        }
        if (from < 4) {
          await m.createTable(dailyChallenges);
          try {
            await m.addColumn(players, players.puzzlePieces);
            await m.addColumn(players, players.itemPlusTime);
            await m.addColumn(players, players.itemMoreNumbers);
            await m.addColumn(players, players.itemRevealPath);
          } catch (e) {
            print('Migration: Column might already exist: $e');
          }
        }
        if (from < 5) {
          try {
            await m.addColumn(dailyChallenges, dailyChallenges.dailyLevelTime);
          } catch (e) {
            print('Migration: Column dailyLevelTime might already exist, skipping: $e');
          }
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    print('Opening Drift database connection...');
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      print('Database file path: ${file.path}');
      return NativeDatabase.createInBackground(file);
    } catch (e) {
      print('Error opening Drift database: $e');
      rethrow;
    }
  });
}
