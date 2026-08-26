// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$PlayersTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _supabaseIdMeta = const VerificationMeta('supabaseId');
@override
late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>('supabase_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
static const VerificationMeta _usernameMeta = const VerificationMeta('username');
@override
late final GeneratedColumn<String> username = GeneratedColumn<String>('username', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _avatarUrlMeta = const VerificationMeta('avatarUrl');
@override
late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>('avatar_url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
static const VerificationMeta _totalGamesPlayedMeta = const VerificationMeta('totalGamesPlayed');
@override
late final GeneratedColumn<int> totalGamesPlayed = GeneratedColumn<int>('total_games_played', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _highscoreMeta = const VerificationMeta('highscore');
@override
late final GeneratedColumn<int> highscore = GeneratedColumn<int>('highscore', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, supabaseId, username, avatarUrl, totalGamesPlayed, highscore, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'players';
@override
VerificationContext validateIntegrity(Insertable<Player> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('supabase_id')) {
context.handle(_supabaseIdMeta, supabaseId.isAcceptableOrUnknown(data['supabase_id']!, _supabaseIdMeta));}if (data.containsKey('username')) {
context.handle(_usernameMeta, username.isAcceptableOrUnknown(data['username']!, _usernameMeta));} else if (isInserting) {
context.missing(_usernameMeta);
}
if (data.containsKey('avatar_url')) {
context.handle(_avatarUrlMeta, avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));}if (data.containsKey('total_games_played')) {
context.handle(_totalGamesPlayedMeta, totalGamesPlayed.isAcceptableOrUnknown(data['total_games_played']!, _totalGamesPlayedMeta));}if (data.containsKey('highscore')) {
context.handle(_highscoreMeta, highscore.isAcceptableOrUnknown(data['highscore']!, _highscoreMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Player map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Player(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, supabaseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}supabase_id']), username: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}username'])!, avatarUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}avatar_url']), totalGamesPlayed: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total_games_played'])!, highscore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}highscore'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']), );
}
@override
$PlayersTable createAlias(String alias) {
return $PlayersTable(attachedDatabase, alias);}}class Player extends DataClass implements Insertable<Player> 
{
final int id;
final String? supabaseId;
final String username;
final String? avatarUrl;
final int totalGamesPlayed;
final int highscore;
final DateTime? updatedAt;
const Player({required this.id, this.supabaseId, required this.username, this.avatarUrl, required this.totalGamesPlayed, required this.highscore, this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
if (!nullToAbsent || supabaseId != null){map['supabase_id'] = Variable<String>(supabaseId);
}map['username'] = Variable<String>(username);
if (!nullToAbsent || avatarUrl != null){map['avatar_url'] = Variable<String>(avatarUrl);
}map['total_games_played'] = Variable<int>(totalGamesPlayed);
map['highscore'] = Variable<int>(highscore);
if (!nullToAbsent || updatedAt != null){map['updated_at'] = Variable<DateTime>(updatedAt);
}return map; 
}
PlayersCompanion toCompanion(bool nullToAbsent) {
return PlayersCompanion(id: Value(id),supabaseId: supabaseId == null && nullToAbsent ? const Value.absent() : Value(supabaseId),username: Value(username),avatarUrl: avatarUrl == null && nullToAbsent ? const Value.absent() : Value(avatarUrl),totalGamesPlayed: Value(totalGamesPlayed),highscore: Value(highscore),updatedAt: updatedAt == null && nullToAbsent ? const Value.absent() : Value(updatedAt),);
}
factory Player.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Player(id: serializer.fromJson<int>(json['id']),supabaseId: serializer.fromJson<String?>(json['supabaseId']),username: serializer.fromJson<String>(json['username']),avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),totalGamesPlayed: serializer.fromJson<int>(json['totalGamesPlayed']),highscore: serializer.fromJson<int>(json['highscore']),updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'supabaseId': serializer.toJson<String?>(supabaseId),'username': serializer.toJson<String>(username),'avatarUrl': serializer.toJson<String?>(avatarUrl),'totalGamesPlayed': serializer.toJson<int>(totalGamesPlayed),'highscore': serializer.toJson<int>(highscore),'updatedAt': serializer.toJson<DateTime?>(updatedAt),};}Player copyWith({int? id,Value<String?> supabaseId = const Value.absent(),String? username,Value<String?> avatarUrl = const Value.absent(),int? totalGamesPlayed,int? highscore,Value<DateTime?> updatedAt = const Value.absent()}) => Player(id: id ?? this.id,supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,username: username ?? this.username,avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,highscore: highscore ?? this.highscore,updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,);Player copyWithCompanion(PlayersCompanion data) {
return Player(
id: data.id.present ? data.id.value : this.id,supabaseId: data.supabaseId.present ? data.supabaseId.value : this.supabaseId,username: data.username.present ? data.username.value : this.username,avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,totalGamesPlayed: data.totalGamesPlayed.present ? data.totalGamesPlayed.value : this.totalGamesPlayed,highscore: data.highscore.present ? data.highscore.value : this.highscore,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Player(')..write('id: $id, ')..write('supabaseId: $supabaseId, ')..write('username: $username, ')..write('avatarUrl: $avatarUrl, ')..write('totalGamesPlayed: $totalGamesPlayed, ')..write('highscore: $highscore, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, supabaseId, username, avatarUrl, totalGamesPlayed, highscore, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Player && other.id == this.id && other.supabaseId == this.supabaseId && other.username == this.username && other.avatarUrl == this.avatarUrl && other.totalGamesPlayed == this.totalGamesPlayed && other.highscore == this.highscore && other.updatedAt == this.updatedAt);
}class PlayersCompanion extends UpdateCompanion<Player> {
final Value<int> id;
final Value<String?> supabaseId;
final Value<String> username;
final Value<String?> avatarUrl;
final Value<int> totalGamesPlayed;
final Value<int> highscore;
final Value<DateTime?> updatedAt;
const PlayersCompanion({this.id = const Value.absent(),this.supabaseId = const Value.absent(),this.username = const Value.absent(),this.avatarUrl = const Value.absent(),this.totalGamesPlayed = const Value.absent(),this.highscore = const Value.absent(),this.updatedAt = const Value.absent(),});
PlayersCompanion.insert({this.id = const Value.absent(),this.supabaseId = const Value.absent(),required String username,this.avatarUrl = const Value.absent(),this.totalGamesPlayed = const Value.absent(),this.highscore = const Value.absent(),this.updatedAt = const Value.absent(),}): username = Value(username);
static Insertable<Player> custom({Expression<int>? id, 
Expression<String>? supabaseId, 
Expression<String>? username, 
Expression<String>? avatarUrl, 
Expression<int>? totalGamesPlayed, 
Expression<int>? highscore, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (supabaseId != null)'supabase_id': supabaseId,if (username != null)'username': username,if (avatarUrl != null)'avatar_url': avatarUrl,if (totalGamesPlayed != null)'total_games_played': totalGamesPlayed,if (highscore != null)'highscore': highscore,if (updatedAt != null)'updated_at': updatedAt,});
}PlayersCompanion copyWith({Value<int>? id, Value<String?>? supabaseId, Value<String>? username, Value<String?>? avatarUrl, Value<int>? totalGamesPlayed, Value<int>? highscore, Value<DateTime?>? updatedAt}) {
return PlayersCompanion(id: id ?? this.id,supabaseId: supabaseId ?? this.supabaseId,username: username ?? this.username,avatarUrl: avatarUrl ?? this.avatarUrl,totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,highscore: highscore ?? this.highscore,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (supabaseId.present) {
map['supabase_id'] = Variable<String>(supabaseId.value);}
if (username.present) {
map['username'] = Variable<String>(username.value);}
if (avatarUrl.present) {
map['avatar_url'] = Variable<String>(avatarUrl.value);}
if (totalGamesPlayed.present) {
map['total_games_played'] = Variable<int>(totalGamesPlayed.value);}
if (highscore.present) {
map['highscore'] = Variable<int>(highscore.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PlayersCompanion(')..write('id: $id, ')..write('supabaseId: $supabaseId, ')..write('username: $username, ')..write('avatarUrl: $avatarUrl, ')..write('totalGamesPlayed: $totalGamesPlayed, ')..write('highscore: $highscore, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
class $ProgressionsTable extends Progressions with TableInfo<$ProgressionsTable, Progression>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$ProgressionsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _playerSupabaseIdMeta = const VerificationMeta('playerSupabaseId');
@override
late final GeneratedColumn<String> playerSupabaseId = GeneratedColumn<String>('player_supabase_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
static const VerificationMeta _currentLevelMeta = const VerificationMeta('currentLevel');
@override
late final GeneratedColumn<int> currentLevel = GeneratedColumn<int>('current_level', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(1));
static const VerificationMeta _unlockedWorldsMeta = const VerificationMeta('unlockedWorlds');
@override
late final GeneratedColumnWithTypeConverter<List<String>, String> unlockedWorlds = GeneratedColumn<String>('unlocked_worlds', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true).withConverter<List<String>>($ProgressionsTable.$converterunlockedWorlds);
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, playerSupabaseId, currentLevel, unlockedWorlds, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'progressions';
@override
VerificationContext validateIntegrity(Insertable<Progression> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('player_supabase_id')) {
context.handle(_playerSupabaseIdMeta, playerSupabaseId.isAcceptableOrUnknown(data['player_supabase_id']!, _playerSupabaseIdMeta));}if (data.containsKey('current_level')) {
context.handle(_currentLevelMeta, currentLevel.isAcceptableOrUnknown(data['current_level']!, _currentLevelMeta));}context.handle(_unlockedWorldsMeta, const VerificationResult.success());if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Progression map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Progression(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, playerSupabaseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}player_supabase_id']), currentLevel: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}current_level'])!, unlockedWorlds: $ProgressionsTable.$converterunlockedWorlds.fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}unlocked_worlds'])!), updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']), );
}
@override
$ProgressionsTable createAlias(String alias) {
return $ProgressionsTable(attachedDatabase, alias);}static TypeConverter<List<String>,String> $converterunlockedWorlds = const WorldListConverter();}class Progression extends DataClass implements Insertable<Progression> 
{
final int id;
final String? playerSupabaseId;
final int currentLevel;
final List<String> unlockedWorlds;
final DateTime? updatedAt;
const Progression({required this.id, this.playerSupabaseId, required this.currentLevel, required this.unlockedWorlds, this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
if (!nullToAbsent || playerSupabaseId != null){map['player_supabase_id'] = Variable<String>(playerSupabaseId);
}map['current_level'] = Variable<int>(currentLevel);
{map['unlocked_worlds'] = Variable<String>($ProgressionsTable.$converterunlockedWorlds.toSql(unlockedWorlds));
}if (!nullToAbsent || updatedAt != null){map['updated_at'] = Variable<DateTime>(updatedAt);
}return map; 
}
ProgressionsCompanion toCompanion(bool nullToAbsent) {
return ProgressionsCompanion(id: Value(id),playerSupabaseId: playerSupabaseId == null && nullToAbsent ? const Value.absent() : Value(playerSupabaseId),currentLevel: Value(currentLevel),unlockedWorlds: Value(unlockedWorlds),updatedAt: updatedAt == null && nullToAbsent ? const Value.absent() : Value(updatedAt),);
}
factory Progression.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Progression(id: serializer.fromJson<int>(json['id']),playerSupabaseId: serializer.fromJson<String?>(json['playerSupabaseId']),currentLevel: serializer.fromJson<int>(json['currentLevel']),unlockedWorlds: serializer.fromJson<List<String>>(json['unlockedWorlds']),updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'playerSupabaseId': serializer.toJson<String?>(playerSupabaseId),'currentLevel': serializer.toJson<int>(currentLevel),'unlockedWorlds': serializer.toJson<List<String>>(unlockedWorlds),'updatedAt': serializer.toJson<DateTime?>(updatedAt),};}Progression copyWith({int? id,Value<String?> playerSupabaseId = const Value.absent(),int? currentLevel,List<String>? unlockedWorlds,Value<DateTime?> updatedAt = const Value.absent()}) => Progression(id: id ?? this.id,playerSupabaseId: playerSupabaseId.present ? playerSupabaseId.value : this.playerSupabaseId,currentLevel: currentLevel ?? this.currentLevel,unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,);Progression copyWithCompanion(ProgressionsCompanion data) {
return Progression(
id: data.id.present ? data.id.value : this.id,playerSupabaseId: data.playerSupabaseId.present ? data.playerSupabaseId.value : this.playerSupabaseId,currentLevel: data.currentLevel.present ? data.currentLevel.value : this.currentLevel,unlockedWorlds: data.unlockedWorlds.present ? data.unlockedWorlds.value : this.unlockedWorlds,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Progression(')..write('id: $id, ')..write('playerSupabaseId: $playerSupabaseId, ')..write('currentLevel: $currentLevel, ')..write('unlockedWorlds: $unlockedWorlds, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, playerSupabaseId, currentLevel, unlockedWorlds, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Progression && other.id == this.id && other.playerSupabaseId == this.playerSupabaseId && other.currentLevel == this.currentLevel && other.unlockedWorlds == this.unlockedWorlds && other.updatedAt == this.updatedAt);
}class ProgressionsCompanion extends UpdateCompanion<Progression> {
final Value<int> id;
final Value<String?> playerSupabaseId;
final Value<int> currentLevel;
final Value<List<String>> unlockedWorlds;
final Value<DateTime?> updatedAt;
const ProgressionsCompanion({this.id = const Value.absent(),this.playerSupabaseId = const Value.absent(),this.currentLevel = const Value.absent(),this.unlockedWorlds = const Value.absent(),this.updatedAt = const Value.absent(),});
ProgressionsCompanion.insert({this.id = const Value.absent(),this.playerSupabaseId = const Value.absent(),this.currentLevel = const Value.absent(),required List<String> unlockedWorlds,this.updatedAt = const Value.absent(),}): unlockedWorlds = Value(unlockedWorlds);
static Insertable<Progression> custom({Expression<int>? id, 
Expression<String>? playerSupabaseId, 
Expression<int>? currentLevel, 
Expression<String>? unlockedWorlds, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (playerSupabaseId != null)'player_supabase_id': playerSupabaseId,if (currentLevel != null)'current_level': currentLevel,if (unlockedWorlds != null)'unlocked_worlds': unlockedWorlds,if (updatedAt != null)'updated_at': updatedAt,});
}ProgressionsCompanion copyWith({Value<int>? id, Value<String?>? playerSupabaseId, Value<int>? currentLevel, Value<List<String>>? unlockedWorlds, Value<DateTime?>? updatedAt}) {
return ProgressionsCompanion(id: id ?? this.id,playerSupabaseId: playerSupabaseId ?? this.playerSupabaseId,currentLevel: currentLevel ?? this.currentLevel,unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (playerSupabaseId.present) {
map['player_supabase_id'] = Variable<String>(playerSupabaseId.value);}
if (currentLevel.present) {
map['current_level'] = Variable<int>(currentLevel.value);}
if (unlockedWorlds.present) {
map['unlocked_worlds'] = Variable<String>($ProgressionsTable.$converterunlockedWorlds.toSql(unlockedWorlds.value));}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('ProgressionsCompanion(')..write('id: $id, ')..write('playerSupabaseId: $playerSupabaseId, ')..write('currentLevel: $currentLevel, ')..write('unlockedWorlds: $unlockedWorlds, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $PlayersTable players = $PlayersTable(this);
late final $ProgressionsTable progressions = $ProgressionsTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [players, progressions];
}
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({Value<int> id,Value<String?> supabaseId,required String username,Value<String?> avatarUrl,Value<int> totalGamesPlayed,Value<int> highscore,Value<DateTime?> updatedAt,});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({Value<int> id,Value<String?> supabaseId,Value<String> username,Value<String?> avatarUrl,Value<int> totalGamesPlayed,Value<int> highscore,Value<DateTime?> updatedAt,});
class $$PlayersTableFilterComposer extends Composer<
        _$AppDatabase,
        $PlayersTable> {
        $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get username => $composableBuilder(
      column: $table.username,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get totalGamesPlayed => $composableBuilder(
      column: $table.totalGamesPlayed,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get highscore => $composableBuilder(
      column: $table.highscore,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$PlayersTableOrderingComposer extends Composer<
        _$AppDatabase,
        $PlayersTable> {
        $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get totalGamesPlayed => $composableBuilder(
      column: $table.totalGamesPlayed,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get highscore => $composableBuilder(
      column: $table.highscore,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$PlayersTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $PlayersTable> {
        $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId,
      builder: (column) => column);
      
GeneratedColumn<String> get username => $composableBuilder(
      column: $table.username,
      builder: (column) => column);
      
GeneratedColumn<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl,
      builder: (column) => column);
      
GeneratedColumn<int> get totalGamesPlayed => $composableBuilder(
      column: $table.totalGamesPlayed,
      builder: (column) => column);
      
GeneratedColumn<int> get highscore => $composableBuilder(
      column: $table.highscore,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$PlayersTableTableManager extends RootTableManager    <_$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player,BaseReferences<_$AppDatabase,$PlayersTable,Player>),
    Player,
    PrefetchHooks Function()
    > {
    $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$PlayersTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$PlayersTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$PlayersTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> supabaseId = const Value.absent(),Value<String> username = const Value.absent(),Value<String?> avatarUrl = const Value.absent(),Value<int> totalGamesPlayed = const Value.absent(),Value<int> highscore = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent(),})=> PlayersCompanion(id: id,supabaseId: supabaseId,username: username,avatarUrl: avatarUrl,totalGamesPlayed: totalGamesPlayed,highscore: highscore,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> supabaseId = const Value.absent(),required String username,Value<String?> avatarUrl = const Value.absent(),Value<int> totalGamesPlayed = const Value.absent(),Value<int> highscore = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent(),})=> PlayersCompanion.insert(id: id,supabaseId: supabaseId,username: username,avatarUrl: avatarUrl,totalGamesPlayed: totalGamesPlayed,highscore: highscore,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$PlayersTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player,BaseReferences<_$AppDatabase,$PlayersTable,Player>),
    Player,
    PrefetchHooks Function()
    >;typedef $$ProgressionsTableCreateCompanionBuilder = ProgressionsCompanion Function({Value<int> id,Value<String?> playerSupabaseId,Value<int> currentLevel,required List<String> unlockedWorlds,Value<DateTime?> updatedAt,});
typedef $$ProgressionsTableUpdateCompanionBuilder = ProgressionsCompanion Function({Value<int> id,Value<String?> playerSupabaseId,Value<int> currentLevel,Value<List<String>> unlockedWorlds,Value<DateTime?> updatedAt,});
class $$ProgressionsTableFilterComposer extends Composer<
        _$AppDatabase,
        $ProgressionsTable> {
        $$ProgressionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get playerSupabaseId => $composableBuilder(
      column: $table.playerSupabaseId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel,
      builder: (column) => 
      ColumnFilters(column));
      
          ColumnWithTypeConverterFilters<List<String>,List<String>,String> get unlockedWorlds => $composableBuilder(
      column: $table.unlockedWorlds,
      builder: (column) => 
      ColumnWithTypeConverterFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$ProgressionsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $ProgressionsTable> {
        $$ProgressionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get playerSupabaseId => $composableBuilder(
      column: $table.playerSupabaseId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get unlockedWorlds => $composableBuilder(
      column: $table.unlockedWorlds,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$ProgressionsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $ProgressionsTable> {
        $$ProgressionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get playerSupabaseId => $composableBuilder(
      column: $table.playerSupabaseId,
      builder: (column) => column);
      
GeneratedColumn<int> get currentLevel => $composableBuilder(
      column: $table.currentLevel,
      builder: (column) => column);
      
          GeneratedColumnWithTypeConverter<List<String>,String> get unlockedWorlds => $composableBuilder(
      column: $table.unlockedWorlds,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$ProgressionsTableTableManager extends RootTableManager    <_$AppDatabase,
    $ProgressionsTable,
    Progression,
    $$ProgressionsTableFilterComposer,
    $$ProgressionsTableOrderingComposer,
    $$ProgressionsTableAnnotationComposer,
    $$ProgressionsTableCreateCompanionBuilder,
    $$ProgressionsTableUpdateCompanionBuilder,
    (Progression,BaseReferences<_$AppDatabase,$ProgressionsTable,Progression>),
    Progression,
    PrefetchHooks Function()
    > {
    $$ProgressionsTableTableManager(_$AppDatabase db, $ProgressionsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$ProgressionsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$ProgressionsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$ProgressionsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> playerSupabaseId = const Value.absent(),Value<int> currentLevel = const Value.absent(),Value<List<String>> unlockedWorlds = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent(),})=> ProgressionsCompanion(id: id,playerSupabaseId: playerSupabaseId,currentLevel: currentLevel,unlockedWorlds: unlockedWorlds,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> playerSupabaseId = const Value.absent(),Value<int> currentLevel = const Value.absent(),required List<String> unlockedWorlds,Value<DateTime?> updatedAt = const Value.absent(),})=> ProgressionsCompanion.insert(id: id,playerSupabaseId: playerSupabaseId,currentLevel: currentLevel,unlockedWorlds: unlockedWorlds,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$ProgressionsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $ProgressionsTable,
    Progression,
    $$ProgressionsTableFilterComposer,
    $$ProgressionsTableOrderingComposer,
    $$ProgressionsTableAnnotationComposer,
    $$ProgressionsTableCreateCompanionBuilder,
    $$ProgressionsTableUpdateCompanionBuilder,
    (Progression,BaseReferences<_$AppDatabase,$ProgressionsTable,Progression>),
    Progression,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$PlayersTableTableManager get players => $$PlayersTableTableManager(_db, _db.players);
$$ProgressionsTableTableManager get progressions => $$ProgressionsTableTableManager(_db, _db.progressions);
}
