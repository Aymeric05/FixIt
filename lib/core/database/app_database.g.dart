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
static const VerificationMeta _livesMeta = const VerificationMeta('lives');
@override
late final GeneratedColumn<int> lives = GeneratedColumn<int>('lives', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(5));
static const VerificationMeta _puzzlePiecesMeta = const VerificationMeta('puzzlePieces');
@override
late final GeneratedColumn<int> puzzlePieces = GeneratedColumn<int>('puzzle_pieces', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(50));
static const VerificationMeta _itemPlusTimeMeta = const VerificationMeta('itemPlusTime');
@override
late final GeneratedColumn<int> itemPlusTime = GeneratedColumn<int>('item_plus_time', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(5));
static const VerificationMeta _itemMoreNumbersMeta = const VerificationMeta('itemMoreNumbers');
@override
late final GeneratedColumn<int> itemMoreNumbers = GeneratedColumn<int>('item_more_numbers', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(5));
static const VerificationMeta _itemRevealPathMeta = const VerificationMeta('itemRevealPath');
@override
late final GeneratedColumn<int> itemRevealPath = GeneratedColumn<int>('item_reveal_path', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(5));
static const VerificationMeta _lastLifeLostAtMeta = const VerificationMeta('lastLifeLostAt');
@override
late final GeneratedColumn<DateTime> lastLifeLostAt = GeneratedColumn<DateTime>('last_life_lost_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, supabaseId, username, avatarUrl, totalGamesPlayed, highscore, lives, puzzlePieces, itemPlusTime, itemMoreNumbers, itemRevealPath, lastLifeLostAt, updatedAt];
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
context.handle(_highscoreMeta, highscore.isAcceptableOrUnknown(data['highscore']!, _highscoreMeta));}if (data.containsKey('lives')) {
context.handle(_livesMeta, lives.isAcceptableOrUnknown(data['lives']!, _livesMeta));}if (data.containsKey('puzzle_pieces')) {
context.handle(_puzzlePiecesMeta, puzzlePieces.isAcceptableOrUnknown(data['puzzle_pieces']!, _puzzlePiecesMeta));}if (data.containsKey('item_plus_time')) {
context.handle(_itemPlusTimeMeta, itemPlusTime.isAcceptableOrUnknown(data['item_plus_time']!, _itemPlusTimeMeta));}if (data.containsKey('item_more_numbers')) {
context.handle(_itemMoreNumbersMeta, itemMoreNumbers.isAcceptableOrUnknown(data['item_more_numbers']!, _itemMoreNumbersMeta));}if (data.containsKey('item_reveal_path')) {
context.handle(_itemRevealPathMeta, itemRevealPath.isAcceptableOrUnknown(data['item_reveal_path']!, _itemRevealPathMeta));}if (data.containsKey('last_life_lost_at')) {
context.handle(_lastLifeLostAtMeta, lastLifeLostAt.isAcceptableOrUnknown(data['last_life_lost_at']!, _lastLifeLostAtMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Player map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Player(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, supabaseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}supabase_id']), username: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}username'])!, avatarUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}avatar_url']), totalGamesPlayed: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total_games_played'])!, highscore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}highscore'])!, lives: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}lives'])!, puzzlePieces: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}puzzle_pieces'])!, itemPlusTime: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}item_plus_time'])!, itemMoreNumbers: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}item_more_numbers'])!, itemRevealPath: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}item_reveal_path'])!, lastLifeLostAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_life_lost_at']), updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']), );
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
final int lives;
final int puzzlePieces;
final int itemPlusTime;
final int itemMoreNumbers;
final int itemRevealPath;
final DateTime? lastLifeLostAt;
final DateTime? updatedAt;
const Player({required this.id, this.supabaseId, required this.username, this.avatarUrl, required this.totalGamesPlayed, required this.highscore, required this.lives, required this.puzzlePieces, required this.itemPlusTime, required this.itemMoreNumbers, required this.itemRevealPath, this.lastLifeLostAt, this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
if (!nullToAbsent || supabaseId != null){map['supabase_id'] = Variable<String>(supabaseId);
}map['username'] = Variable<String>(username);
if (!nullToAbsent || avatarUrl != null){map['avatar_url'] = Variable<String>(avatarUrl);
}map['total_games_played'] = Variable<int>(totalGamesPlayed);
map['highscore'] = Variable<int>(highscore);
map['lives'] = Variable<int>(lives);
map['puzzle_pieces'] = Variable<int>(puzzlePieces);
map['item_plus_time'] = Variable<int>(itemPlusTime);
map['item_more_numbers'] = Variable<int>(itemMoreNumbers);
map['item_reveal_path'] = Variable<int>(itemRevealPath);
if (!nullToAbsent || lastLifeLostAt != null){map['last_life_lost_at'] = Variable<DateTime>(lastLifeLostAt);
}if (!nullToAbsent || updatedAt != null){map['updated_at'] = Variable<DateTime>(updatedAt);
}return map; 
}
PlayersCompanion toCompanion(bool nullToAbsent) {
return PlayersCompanion(id: Value(id),supabaseId: supabaseId == null && nullToAbsent ? const Value.absent() : Value(supabaseId),username: Value(username),avatarUrl: avatarUrl == null && nullToAbsent ? const Value.absent() : Value(avatarUrl),totalGamesPlayed: Value(totalGamesPlayed),highscore: Value(highscore),lives: Value(lives),puzzlePieces: Value(puzzlePieces),itemPlusTime: Value(itemPlusTime),itemMoreNumbers: Value(itemMoreNumbers),itemRevealPath: Value(itemRevealPath),lastLifeLostAt: lastLifeLostAt == null && nullToAbsent ? const Value.absent() : Value(lastLifeLostAt),updatedAt: updatedAt == null && nullToAbsent ? const Value.absent() : Value(updatedAt),);
}
factory Player.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Player(id: serializer.fromJson<int>(json['id']),supabaseId: serializer.fromJson<String?>(json['supabaseId']),username: serializer.fromJson<String>(json['username']),avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),totalGamesPlayed: serializer.fromJson<int>(json['totalGamesPlayed']),highscore: serializer.fromJson<int>(json['highscore']),lives: serializer.fromJson<int>(json['lives']),puzzlePieces: serializer.fromJson<int>(json['puzzlePieces']),itemPlusTime: serializer.fromJson<int>(json['itemPlusTime']),itemMoreNumbers: serializer.fromJson<int>(json['itemMoreNumbers']),itemRevealPath: serializer.fromJson<int>(json['itemRevealPath']),lastLifeLostAt: serializer.fromJson<DateTime?>(json['lastLifeLostAt']),updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'supabaseId': serializer.toJson<String?>(supabaseId),'username': serializer.toJson<String>(username),'avatarUrl': serializer.toJson<String?>(avatarUrl),'totalGamesPlayed': serializer.toJson<int>(totalGamesPlayed),'highscore': serializer.toJson<int>(highscore),'lives': serializer.toJson<int>(lives),'puzzlePieces': serializer.toJson<int>(puzzlePieces),'itemPlusTime': serializer.toJson<int>(itemPlusTime),'itemMoreNumbers': serializer.toJson<int>(itemMoreNumbers),'itemRevealPath': serializer.toJson<int>(itemRevealPath),'lastLifeLostAt': serializer.toJson<DateTime?>(lastLifeLostAt),'updatedAt': serializer.toJson<DateTime?>(updatedAt),};}Player copyWith({int? id,Value<String?> supabaseId = const Value.absent(),String? username,Value<String?> avatarUrl = const Value.absent(),int? totalGamesPlayed,int? highscore,int? lives,int? puzzlePieces,int? itemPlusTime,int? itemMoreNumbers,int? itemRevealPath,Value<DateTime?> lastLifeLostAt = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent()}) => Player(id: id ?? this.id,supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,username: username ?? this.username,avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,highscore: highscore ?? this.highscore,lives: lives ?? this.lives,puzzlePieces: puzzlePieces ?? this.puzzlePieces,itemPlusTime: itemPlusTime ?? this.itemPlusTime,itemMoreNumbers: itemMoreNumbers ?? this.itemMoreNumbers,itemRevealPath: itemRevealPath ?? this.itemRevealPath,lastLifeLostAt: lastLifeLostAt.present ? lastLifeLostAt.value : this.lastLifeLostAt,updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,);Player copyWithCompanion(PlayersCompanion data) {
return Player(
id: data.id.present ? data.id.value : this.id,supabaseId: data.supabaseId.present ? data.supabaseId.value : this.supabaseId,username: data.username.present ? data.username.value : this.username,avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,totalGamesPlayed: data.totalGamesPlayed.present ? data.totalGamesPlayed.value : this.totalGamesPlayed,highscore: data.highscore.present ? data.highscore.value : this.highscore,lives: data.lives.present ? data.lives.value : this.lives,puzzlePieces: data.puzzlePieces.present ? data.puzzlePieces.value : this.puzzlePieces,itemPlusTime: data.itemPlusTime.present ? data.itemPlusTime.value : this.itemPlusTime,itemMoreNumbers: data.itemMoreNumbers.present ? data.itemMoreNumbers.value : this.itemMoreNumbers,itemRevealPath: data.itemRevealPath.present ? data.itemRevealPath.value : this.itemRevealPath,lastLifeLostAt: data.lastLifeLostAt.present ? data.lastLifeLostAt.value : this.lastLifeLostAt,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Player(')..write('id: $id, ')..write('supabaseId: $supabaseId, ')..write('username: $username, ')..write('avatarUrl: $avatarUrl, ')..write('totalGamesPlayed: $totalGamesPlayed, ')..write('highscore: $highscore, ')..write('lives: $lives, ')..write('puzzlePieces: $puzzlePieces, ')..write('itemPlusTime: $itemPlusTime, ')..write('itemMoreNumbers: $itemMoreNumbers, ')..write('itemRevealPath: $itemRevealPath, ')..write('lastLifeLostAt: $lastLifeLostAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, supabaseId, username, avatarUrl, totalGamesPlayed, highscore, lives, puzzlePieces, itemPlusTime, itemMoreNumbers, itemRevealPath, lastLifeLostAt, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Player && other.id == this.id && other.supabaseId == this.supabaseId && other.username == this.username && other.avatarUrl == this.avatarUrl && other.totalGamesPlayed == this.totalGamesPlayed && other.highscore == this.highscore && other.lives == this.lives && other.puzzlePieces == this.puzzlePieces && other.itemPlusTime == this.itemPlusTime && other.itemMoreNumbers == this.itemMoreNumbers && other.itemRevealPath == this.itemRevealPath && other.lastLifeLostAt == this.lastLifeLostAt && other.updatedAt == this.updatedAt);
}class PlayersCompanion extends UpdateCompanion<Player> {
final Value<int> id;
final Value<String?> supabaseId;
final Value<String> username;
final Value<String?> avatarUrl;
final Value<int> totalGamesPlayed;
final Value<int> highscore;
final Value<int> lives;
final Value<int> puzzlePieces;
final Value<int> itemPlusTime;
final Value<int> itemMoreNumbers;
final Value<int> itemRevealPath;
final Value<DateTime?> lastLifeLostAt;
final Value<DateTime?> updatedAt;
const PlayersCompanion({this.id = const Value.absent(),this.supabaseId = const Value.absent(),this.username = const Value.absent(),this.avatarUrl = const Value.absent(),this.totalGamesPlayed = const Value.absent(),this.highscore = const Value.absent(),this.lives = const Value.absent(),this.puzzlePieces = const Value.absent(),this.itemPlusTime = const Value.absent(),this.itemMoreNumbers = const Value.absent(),this.itemRevealPath = const Value.absent(),this.lastLifeLostAt = const Value.absent(),this.updatedAt = const Value.absent(),});
PlayersCompanion.insert({this.id = const Value.absent(),this.supabaseId = const Value.absent(),required String username,this.avatarUrl = const Value.absent(),this.totalGamesPlayed = const Value.absent(),this.highscore = const Value.absent(),this.lives = const Value.absent(),this.puzzlePieces = const Value.absent(),this.itemPlusTime = const Value.absent(),this.itemMoreNumbers = const Value.absent(),this.itemRevealPath = const Value.absent(),this.lastLifeLostAt = const Value.absent(),this.updatedAt = const Value.absent(),}): username = Value(username);
static Insertable<Player> custom({Expression<int>? id, 
Expression<String>? supabaseId, 
Expression<String>? username, 
Expression<String>? avatarUrl, 
Expression<int>? totalGamesPlayed, 
Expression<int>? highscore, 
Expression<int>? lives, 
Expression<int>? puzzlePieces, 
Expression<int>? itemPlusTime, 
Expression<int>? itemMoreNumbers, 
Expression<int>? itemRevealPath, 
Expression<DateTime>? lastLifeLostAt, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (supabaseId != null)'supabase_id': supabaseId,if (username != null)'username': username,if (avatarUrl != null)'avatar_url': avatarUrl,if (totalGamesPlayed != null)'total_games_played': totalGamesPlayed,if (highscore != null)'highscore': highscore,if (lives != null)'lives': lives,if (puzzlePieces != null)'puzzle_pieces': puzzlePieces,if (itemPlusTime != null)'item_plus_time': itemPlusTime,if (itemMoreNumbers != null)'item_more_numbers': itemMoreNumbers,if (itemRevealPath != null)'item_reveal_path': itemRevealPath,if (lastLifeLostAt != null)'last_life_lost_at': lastLifeLostAt,if (updatedAt != null)'updated_at': updatedAt,});
}PlayersCompanion copyWith({Value<int>? id, Value<String?>? supabaseId, Value<String>? username, Value<String?>? avatarUrl, Value<int>? totalGamesPlayed, Value<int>? highscore, Value<int>? lives, Value<int>? puzzlePieces, Value<int>? itemPlusTime, Value<int>? itemMoreNumbers, Value<int>? itemRevealPath, Value<DateTime?>? lastLifeLostAt, Value<DateTime?>? updatedAt}) {
return PlayersCompanion(id: id ?? this.id,supabaseId: supabaseId ?? this.supabaseId,username: username ?? this.username,avatarUrl: avatarUrl ?? this.avatarUrl,totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,highscore: highscore ?? this.highscore,lives: lives ?? this.lives,puzzlePieces: puzzlePieces ?? this.puzzlePieces,itemPlusTime: itemPlusTime ?? this.itemPlusTime,itemMoreNumbers: itemMoreNumbers ?? this.itemMoreNumbers,itemRevealPath: itemRevealPath ?? this.itemRevealPath,lastLifeLostAt: lastLifeLostAt ?? this.lastLifeLostAt,updatedAt: updatedAt ?? this.updatedAt,);
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
if (lives.present) {
map['lives'] = Variable<int>(lives.value);}
if (puzzlePieces.present) {
map['puzzle_pieces'] = Variable<int>(puzzlePieces.value);}
if (itemPlusTime.present) {
map['item_plus_time'] = Variable<int>(itemPlusTime.value);}
if (itemMoreNumbers.present) {
map['item_more_numbers'] = Variable<int>(itemMoreNumbers.value);}
if (itemRevealPath.present) {
map['item_reveal_path'] = Variable<int>(itemRevealPath.value);}
if (lastLifeLostAt.present) {
map['last_life_lost_at'] = Variable<DateTime>(lastLifeLostAt.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PlayersCompanion(')..write('id: $id, ')..write('supabaseId: $supabaseId, ')..write('username: $username, ')..write('avatarUrl: $avatarUrl, ')..write('totalGamesPlayed: $totalGamesPlayed, ')..write('highscore: $highscore, ')..write('lives: $lives, ')..write('puzzlePieces: $puzzlePieces, ')..write('itemPlusTime: $itemPlusTime, ')..write('itemMoreNumbers: $itemMoreNumbers, ')..write('itemRevealPath: $itemRevealPath, ')..write('lastLifeLostAt: $lastLifeLostAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
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
class $LevelCompletionsTable extends LevelCompletions with TableInfo<$LevelCompletionsTable, LevelCompletion>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$LevelCompletionsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _playerSupabaseIdMeta = const VerificationMeta('playerSupabaseId');
@override
late final GeneratedColumn<String> playerSupabaseId = GeneratedColumn<String>('player_supabase_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _worldIdMeta = const VerificationMeta('worldId');
@override
late final GeneratedColumn<String> worldId = GeneratedColumn<String>('world_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _levelNumberMeta = const VerificationMeta('levelNumber');
@override
late final GeneratedColumn<int> levelNumber = GeneratedColumn<int>('level_number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _completionTimeSecondsMeta = const VerificationMeta('completionTimeSeconds');
@override
late final GeneratedColumn<int> completionTimeSeconds = GeneratedColumn<int>('completion_time_seconds', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
@override
late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>('completed_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, playerSupabaseId, worldId, levelNumber, completionTimeSeconds, completedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'level_completions';
@override
VerificationContext validateIntegrity(Insertable<LevelCompletion> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('player_supabase_id')) {
context.handle(_playerSupabaseIdMeta, playerSupabaseId.isAcceptableOrUnknown(data['player_supabase_id']!, _playerSupabaseIdMeta));} else if (isInserting) {
context.missing(_playerSupabaseIdMeta);
}
if (data.containsKey('world_id')) {
context.handle(_worldIdMeta, worldId.isAcceptableOrUnknown(data['world_id']!, _worldIdMeta));} else if (isInserting) {
context.missing(_worldIdMeta);
}
if (data.containsKey('level_number')) {
context.handle(_levelNumberMeta, levelNumber.isAcceptableOrUnknown(data['level_number']!, _levelNumberMeta));} else if (isInserting) {
context.missing(_levelNumberMeta);
}
if (data.containsKey('completion_time_seconds')) {
context.handle(_completionTimeSecondsMeta, completionTimeSeconds.isAcceptableOrUnknown(data['completion_time_seconds']!, _completionTimeSecondsMeta));} else if (isInserting) {
context.missing(_completionTimeSecondsMeta);
}
if (data.containsKey('completed_at')) {
context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override
List<Set<GeneratedColumn>> get uniqueKeys => [{playerSupabaseId, worldId, levelNumber},
];
@override LevelCompletion map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LevelCompletion(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, playerSupabaseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}player_supabase_id'])!, worldId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}world_id'])!, levelNumber: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}level_number'])!, completionTimeSeconds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}completion_time_seconds'])!, completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!, );
}
@override
$LevelCompletionsTable createAlias(String alias) {
return $LevelCompletionsTable(attachedDatabase, alias);}}class LevelCompletion extends DataClass implements Insertable<LevelCompletion> 
{
final int id;
final String playerSupabaseId;
final String worldId;
final int levelNumber;
final int completionTimeSeconds;
final DateTime completedAt;
const LevelCompletion({required this.id, required this.playerSupabaseId, required this.worldId, required this.levelNumber, required this.completionTimeSeconds, required this.completedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['player_supabase_id'] = Variable<String>(playerSupabaseId);
map['world_id'] = Variable<String>(worldId);
map['level_number'] = Variable<int>(levelNumber);
map['completion_time_seconds'] = Variable<int>(completionTimeSeconds);
map['completed_at'] = Variable<DateTime>(completedAt);
return map; 
}
LevelCompletionsCompanion toCompanion(bool nullToAbsent) {
return LevelCompletionsCompanion(id: Value(id),playerSupabaseId: Value(playerSupabaseId),worldId: Value(worldId),levelNumber: Value(levelNumber),completionTimeSeconds: Value(completionTimeSeconds),completedAt: Value(completedAt),);
}
factory LevelCompletion.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LevelCompletion(id: serializer.fromJson<int>(json['id']),playerSupabaseId: serializer.fromJson<String>(json['playerSupabaseId']),worldId: serializer.fromJson<String>(json['worldId']),levelNumber: serializer.fromJson<int>(json['levelNumber']),completionTimeSeconds: serializer.fromJson<int>(json['completionTimeSeconds']),completedAt: serializer.fromJson<DateTime>(json['completedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'playerSupabaseId': serializer.toJson<String>(playerSupabaseId),'worldId': serializer.toJson<String>(worldId),'levelNumber': serializer.toJson<int>(levelNumber),'completionTimeSeconds': serializer.toJson<int>(completionTimeSeconds),'completedAt': serializer.toJson<DateTime>(completedAt),};}LevelCompletion copyWith({int? id,String? playerSupabaseId,String? worldId,int? levelNumber,int? completionTimeSeconds,DateTime? completedAt}) => LevelCompletion(id: id ?? this.id,playerSupabaseId: playerSupabaseId ?? this.playerSupabaseId,worldId: worldId ?? this.worldId,levelNumber: levelNumber ?? this.levelNumber,completionTimeSeconds: completionTimeSeconds ?? this.completionTimeSeconds,completedAt: completedAt ?? this.completedAt,);LevelCompletion copyWithCompanion(LevelCompletionsCompanion data) {
return LevelCompletion(
id: data.id.present ? data.id.value : this.id,playerSupabaseId: data.playerSupabaseId.present ? data.playerSupabaseId.value : this.playerSupabaseId,worldId: data.worldId.present ? data.worldId.value : this.worldId,levelNumber: data.levelNumber.present ? data.levelNumber.value : this.levelNumber,completionTimeSeconds: data.completionTimeSeconds.present ? data.completionTimeSeconds.value : this.completionTimeSeconds,completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,);
}
@override
String toString() {return (StringBuffer('LevelCompletion(')..write('id: $id, ')..write('playerSupabaseId: $playerSupabaseId, ')..write('worldId: $worldId, ')..write('levelNumber: $levelNumber, ')..write('completionTimeSeconds: $completionTimeSeconds, ')..write('completedAt: $completedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, playerSupabaseId, worldId, levelNumber, completionTimeSeconds, completedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is LevelCompletion && other.id == this.id && other.playerSupabaseId == this.playerSupabaseId && other.worldId == this.worldId && other.levelNumber == this.levelNumber && other.completionTimeSeconds == this.completionTimeSeconds && other.completedAt == this.completedAt);
}class LevelCompletionsCompanion extends UpdateCompanion<LevelCompletion> {
final Value<int> id;
final Value<String> playerSupabaseId;
final Value<String> worldId;
final Value<int> levelNumber;
final Value<int> completionTimeSeconds;
final Value<DateTime> completedAt;
const LevelCompletionsCompanion({this.id = const Value.absent(),this.playerSupabaseId = const Value.absent(),this.worldId = const Value.absent(),this.levelNumber = const Value.absent(),this.completionTimeSeconds = const Value.absent(),this.completedAt = const Value.absent(),});
LevelCompletionsCompanion.insert({this.id = const Value.absent(),required String playerSupabaseId,required String worldId,required int levelNumber,required int completionTimeSeconds,this.completedAt = const Value.absent(),}): playerSupabaseId = Value(playerSupabaseId), worldId = Value(worldId), levelNumber = Value(levelNumber), completionTimeSeconds = Value(completionTimeSeconds);
static Insertable<LevelCompletion> custom({Expression<int>? id, 
Expression<String>? playerSupabaseId, 
Expression<String>? worldId, 
Expression<int>? levelNumber, 
Expression<int>? completionTimeSeconds, 
Expression<DateTime>? completedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (playerSupabaseId != null)'player_supabase_id': playerSupabaseId,if (worldId != null)'world_id': worldId,if (levelNumber != null)'level_number': levelNumber,if (completionTimeSeconds != null)'completion_time_seconds': completionTimeSeconds,if (completedAt != null)'completed_at': completedAt,});
}LevelCompletionsCompanion copyWith({Value<int>? id, Value<String>? playerSupabaseId, Value<String>? worldId, Value<int>? levelNumber, Value<int>? completionTimeSeconds, Value<DateTime>? completedAt}) {
return LevelCompletionsCompanion(id: id ?? this.id,playerSupabaseId: playerSupabaseId ?? this.playerSupabaseId,worldId: worldId ?? this.worldId,levelNumber: levelNumber ?? this.levelNumber,completionTimeSeconds: completionTimeSeconds ?? this.completionTimeSeconds,completedAt: completedAt ?? this.completedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (playerSupabaseId.present) {
map['player_supabase_id'] = Variable<String>(playerSupabaseId.value);}
if (worldId.present) {
map['world_id'] = Variable<String>(worldId.value);}
if (levelNumber.present) {
map['level_number'] = Variable<int>(levelNumber.value);}
if (completionTimeSeconds.present) {
map['completion_time_seconds'] = Variable<int>(completionTimeSeconds.value);}
if (completedAt.present) {
map['completed_at'] = Variable<DateTime>(completedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('LevelCompletionsCompanion(')..write('id: $id, ')..write('playerSupabaseId: $playerSupabaseId, ')..write('worldId: $worldId, ')..write('levelNumber: $levelNumber, ')..write('completionTimeSeconds: $completionTimeSeconds, ')..write('completedAt: $completedAt')..write(')')).toString();}
}
class $GlobalLevelsTable extends GlobalLevels with TableInfo<$GlobalLevelsTable, GlobalLevel>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$GlobalLevelsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _worldIdMeta = const VerificationMeta('worldId');
@override
late final GeneratedColumn<String> worldId = GeneratedColumn<String>('world_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _levelNumberMeta = const VerificationMeta('levelNumber');
@override
late final GeneratedColumn<int> levelNumber = GeneratedColumn<int>('level_number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _hintsJsonMeta = const VerificationMeta('hintsJson');
@override
late final GeneratedColumn<String> hintsJson = GeneratedColumn<String>('hints_json', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _wallsJsonMeta = const VerificationMeta('wallsJson');
@override
late final GeneratedColumn<String> wallsJson = GeneratedColumn<String>('walls_json', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _solutionJsonMeta = const VerificationMeta('solutionJson');
@override
late final GeneratedColumn<String> solutionJson = GeneratedColumn<String>('solution_json', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, worldId, levelNumber, hintsJson, wallsJson, solutionJson, createdAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'global_levels';
@override
VerificationContext validateIntegrity(Insertable<GlobalLevel> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('world_id')) {
context.handle(_worldIdMeta, worldId.isAcceptableOrUnknown(data['world_id']!, _worldIdMeta));} else if (isInserting) {
context.missing(_worldIdMeta);
}
if (data.containsKey('level_number')) {
context.handle(_levelNumberMeta, levelNumber.isAcceptableOrUnknown(data['level_number']!, _levelNumberMeta));} else if (isInserting) {
context.missing(_levelNumberMeta);
}
if (data.containsKey('hints_json')) {
context.handle(_hintsJsonMeta, hintsJson.isAcceptableOrUnknown(data['hints_json']!, _hintsJsonMeta));} else if (isInserting) {
context.missing(_hintsJsonMeta);
}
if (data.containsKey('walls_json')) {
context.handle(_wallsJsonMeta, wallsJson.isAcceptableOrUnknown(data['walls_json']!, _wallsJsonMeta));} else if (isInserting) {
context.missing(_wallsJsonMeta);
}
if (data.containsKey('solution_json')) {
context.handle(_solutionJsonMeta, solutionJson.isAcceptableOrUnknown(data['solution_json']!, _solutionJsonMeta));} else if (isInserting) {
context.missing(_solutionJsonMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override
List<Set<GeneratedColumn>> get uniqueKeys => [{worldId, levelNumber},
];
@override GlobalLevel map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return GlobalLevel(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, worldId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}world_id'])!, levelNumber: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}level_number'])!, hintsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hints_json'])!, wallsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}walls_json'])!, solutionJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}solution_json'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, );
}
@override
$GlobalLevelsTable createAlias(String alias) {
return $GlobalLevelsTable(attachedDatabase, alias);}}class GlobalLevel extends DataClass implements Insertable<GlobalLevel> 
{
final int id;
final String worldId;
final int levelNumber;
final String hintsJson;
final String wallsJson;
final String solutionJson;
final DateTime createdAt;
const GlobalLevel({required this.id, required this.worldId, required this.levelNumber, required this.hintsJson, required this.wallsJson, required this.solutionJson, required this.createdAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['world_id'] = Variable<String>(worldId);
map['level_number'] = Variable<int>(levelNumber);
map['hints_json'] = Variable<String>(hintsJson);
map['walls_json'] = Variable<String>(wallsJson);
map['solution_json'] = Variable<String>(solutionJson);
map['created_at'] = Variable<DateTime>(createdAt);
return map; 
}
GlobalLevelsCompanion toCompanion(bool nullToAbsent) {
return GlobalLevelsCompanion(id: Value(id),worldId: Value(worldId),levelNumber: Value(levelNumber),hintsJson: Value(hintsJson),wallsJson: Value(wallsJson),solutionJson: Value(solutionJson),createdAt: Value(createdAt),);
}
factory GlobalLevel.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return GlobalLevel(id: serializer.fromJson<int>(json['id']),worldId: serializer.fromJson<String>(json['worldId']),levelNumber: serializer.fromJson<int>(json['levelNumber']),hintsJson: serializer.fromJson<String>(json['hintsJson']),wallsJson: serializer.fromJson<String>(json['wallsJson']),solutionJson: serializer.fromJson<String>(json['solutionJson']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'worldId': serializer.toJson<String>(worldId),'levelNumber': serializer.toJson<int>(levelNumber),'hintsJson': serializer.toJson<String>(hintsJson),'wallsJson': serializer.toJson<String>(wallsJson),'solutionJson': serializer.toJson<String>(solutionJson),'createdAt': serializer.toJson<DateTime>(createdAt),};}GlobalLevel copyWith({int? id,String? worldId,int? levelNumber,String? hintsJson,String? wallsJson,String? solutionJson,DateTime? createdAt}) => GlobalLevel(id: id ?? this.id,worldId: worldId ?? this.worldId,levelNumber: levelNumber ?? this.levelNumber,hintsJson: hintsJson ?? this.hintsJson,wallsJson: wallsJson ?? this.wallsJson,solutionJson: solutionJson ?? this.solutionJson,createdAt: createdAt ?? this.createdAt,);GlobalLevel copyWithCompanion(GlobalLevelsCompanion data) {
return GlobalLevel(
id: data.id.present ? data.id.value : this.id,worldId: data.worldId.present ? data.worldId.value : this.worldId,levelNumber: data.levelNumber.present ? data.levelNumber.value : this.levelNumber,hintsJson: data.hintsJson.present ? data.hintsJson.value : this.hintsJson,wallsJson: data.wallsJson.present ? data.wallsJson.value : this.wallsJson,solutionJson: data.solutionJson.present ? data.solutionJson.value : this.solutionJson,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,);
}
@override
String toString() {return (StringBuffer('GlobalLevel(')..write('id: $id, ')..write('worldId: $worldId, ')..write('levelNumber: $levelNumber, ')..write('hintsJson: $hintsJson, ')..write('wallsJson: $wallsJson, ')..write('solutionJson: $solutionJson, ')..write('createdAt: $createdAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, worldId, levelNumber, hintsJson, wallsJson, solutionJson, createdAt);@override
bool operator ==(Object other) => identical(this, other) || (other is GlobalLevel && other.id == this.id && other.worldId == this.worldId && other.levelNumber == this.levelNumber && other.hintsJson == this.hintsJson && other.wallsJson == this.wallsJson && other.solutionJson == this.solutionJson && other.createdAt == this.createdAt);
}class GlobalLevelsCompanion extends UpdateCompanion<GlobalLevel> {
final Value<int> id;
final Value<String> worldId;
final Value<int> levelNumber;
final Value<String> hintsJson;
final Value<String> wallsJson;
final Value<String> solutionJson;
final Value<DateTime> createdAt;
const GlobalLevelsCompanion({this.id = const Value.absent(),this.worldId = const Value.absent(),this.levelNumber = const Value.absent(),this.hintsJson = const Value.absent(),this.wallsJson = const Value.absent(),this.solutionJson = const Value.absent(),this.createdAt = const Value.absent(),});
GlobalLevelsCompanion.insert({this.id = const Value.absent(),required String worldId,required int levelNumber,required String hintsJson,required String wallsJson,required String solutionJson,this.createdAt = const Value.absent(),}): worldId = Value(worldId), levelNumber = Value(levelNumber), hintsJson = Value(hintsJson), wallsJson = Value(wallsJson), solutionJson = Value(solutionJson);
static Insertable<GlobalLevel> custom({Expression<int>? id, 
Expression<String>? worldId, 
Expression<int>? levelNumber, 
Expression<String>? hintsJson, 
Expression<String>? wallsJson, 
Expression<String>? solutionJson, 
Expression<DateTime>? createdAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (worldId != null)'world_id': worldId,if (levelNumber != null)'level_number': levelNumber,if (hintsJson != null)'hints_json': hintsJson,if (wallsJson != null)'walls_json': wallsJson,if (solutionJson != null)'solution_json': solutionJson,if (createdAt != null)'created_at': createdAt,});
}GlobalLevelsCompanion copyWith({Value<int>? id, Value<String>? worldId, Value<int>? levelNumber, Value<String>? hintsJson, Value<String>? wallsJson, Value<String>? solutionJson, Value<DateTime>? createdAt}) {
return GlobalLevelsCompanion(id: id ?? this.id,worldId: worldId ?? this.worldId,levelNumber: levelNumber ?? this.levelNumber,hintsJson: hintsJson ?? this.hintsJson,wallsJson: wallsJson ?? this.wallsJson,solutionJson: solutionJson ?? this.solutionJson,createdAt: createdAt ?? this.createdAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (worldId.present) {
map['world_id'] = Variable<String>(worldId.value);}
if (levelNumber.present) {
map['level_number'] = Variable<int>(levelNumber.value);}
if (hintsJson.present) {
map['hints_json'] = Variable<String>(hintsJson.value);}
if (wallsJson.present) {
map['walls_json'] = Variable<String>(wallsJson.value);}
if (solutionJson.present) {
map['solution_json'] = Variable<String>(solutionJson.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('GlobalLevelsCompanion(')..write('id: $id, ')..write('worldId: $worldId, ')..write('levelNumber: $levelNumber, ')..write('hintsJson: $hintsJson, ')..write('wallsJson: $wallsJson, ')..write('solutionJson: $solutionJson, ')..write('createdAt: $createdAt')..write(')')).toString();}
}
class $FriendsTable extends Friends with TableInfo<$FriendsTable, Friend>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$FriendsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _playerIdMeta = const VerificationMeta('playerId');
@override
late final GeneratedColumn<String> playerId = GeneratedColumn<String>('player_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _friendIdMeta = const VerificationMeta('friendId');
@override
late final GeneratedColumn<String> friendId = GeneratedColumn<String>('friend_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _friendUsernameMeta = const VerificationMeta('friendUsername');
@override
late final GeneratedColumn<String> friendUsername = GeneratedColumn<String>('friend_username', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, playerId, friendId, friendUsername, createdAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'friends';
@override
VerificationContext validateIntegrity(Insertable<Friend> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('player_id')) {
context.handle(_playerIdMeta, playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));} else if (isInserting) {
context.missing(_playerIdMeta);
}
if (data.containsKey('friend_id')) {
context.handle(_friendIdMeta, friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));} else if (isInserting) {
context.missing(_friendIdMeta);
}
if (data.containsKey('friend_username')) {
context.handle(_friendUsernameMeta, friendUsername.isAcceptableOrUnknown(data['friend_username']!, _friendUsernameMeta));} else if (isInserting) {
context.missing(_friendUsernameMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override
List<Set<GeneratedColumn>> get uniqueKeys => [{playerId, friendId},
];
@override Friend map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Friend(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, playerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}player_id'])!, friendId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}friend_id'])!, friendUsername: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}friend_username'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, );
}
@override
$FriendsTable createAlias(String alias) {
return $FriendsTable(attachedDatabase, alias);}}class Friend extends DataClass implements Insertable<Friend> 
{
final int id;
final String playerId;
final String friendId;
final String friendUsername;
final DateTime createdAt;
const Friend({required this.id, required this.playerId, required this.friendId, required this.friendUsername, required this.createdAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['player_id'] = Variable<String>(playerId);
map['friend_id'] = Variable<String>(friendId);
map['friend_username'] = Variable<String>(friendUsername);
map['created_at'] = Variable<DateTime>(createdAt);
return map; 
}
FriendsCompanion toCompanion(bool nullToAbsent) {
return FriendsCompanion(id: Value(id),playerId: Value(playerId),friendId: Value(friendId),friendUsername: Value(friendUsername),createdAt: Value(createdAt),);
}
factory Friend.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Friend(id: serializer.fromJson<int>(json['id']),playerId: serializer.fromJson<String>(json['playerId']),friendId: serializer.fromJson<String>(json['friendId']),friendUsername: serializer.fromJson<String>(json['friendUsername']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'playerId': serializer.toJson<String>(playerId),'friendId': serializer.toJson<String>(friendId),'friendUsername': serializer.toJson<String>(friendUsername),'createdAt': serializer.toJson<DateTime>(createdAt),};}Friend copyWith({int? id,String? playerId,String? friendId,String? friendUsername,DateTime? createdAt}) => Friend(id: id ?? this.id,playerId: playerId ?? this.playerId,friendId: friendId ?? this.friendId,friendUsername: friendUsername ?? this.friendUsername,createdAt: createdAt ?? this.createdAt,);Friend copyWithCompanion(FriendsCompanion data) {
return Friend(
id: data.id.present ? data.id.value : this.id,playerId: data.playerId.present ? data.playerId.value : this.playerId,friendId: data.friendId.present ? data.friendId.value : this.friendId,friendUsername: data.friendUsername.present ? data.friendUsername.value : this.friendUsername,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,);
}
@override
String toString() {return (StringBuffer('Friend(')..write('id: $id, ')..write('playerId: $playerId, ')..write('friendId: $friendId, ')..write('friendUsername: $friendUsername, ')..write('createdAt: $createdAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, playerId, friendId, friendUsername, createdAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Friend && other.id == this.id && other.playerId == this.playerId && other.friendId == this.friendId && other.friendUsername == this.friendUsername && other.createdAt == this.createdAt);
}class FriendsCompanion extends UpdateCompanion<Friend> {
final Value<int> id;
final Value<String> playerId;
final Value<String> friendId;
final Value<String> friendUsername;
final Value<DateTime> createdAt;
const FriendsCompanion({this.id = const Value.absent(),this.playerId = const Value.absent(),this.friendId = const Value.absent(),this.friendUsername = const Value.absent(),this.createdAt = const Value.absent(),});
FriendsCompanion.insert({this.id = const Value.absent(),required String playerId,required String friendId,required String friendUsername,this.createdAt = const Value.absent(),}): playerId = Value(playerId), friendId = Value(friendId), friendUsername = Value(friendUsername);
static Insertable<Friend> custom({Expression<int>? id, 
Expression<String>? playerId, 
Expression<String>? friendId, 
Expression<String>? friendUsername, 
Expression<DateTime>? createdAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (playerId != null)'player_id': playerId,if (friendId != null)'friend_id': friendId,if (friendUsername != null)'friend_username': friendUsername,if (createdAt != null)'created_at': createdAt,});
}FriendsCompanion copyWith({Value<int>? id, Value<String>? playerId, Value<String>? friendId, Value<String>? friendUsername, Value<DateTime>? createdAt}) {
return FriendsCompanion(id: id ?? this.id,playerId: playerId ?? this.playerId,friendId: friendId ?? this.friendId,friendUsername: friendUsername ?? this.friendUsername,createdAt: createdAt ?? this.createdAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (playerId.present) {
map['player_id'] = Variable<String>(playerId.value);}
if (friendId.present) {
map['friend_id'] = Variable<String>(friendId.value);}
if (friendUsername.present) {
map['friend_username'] = Variable<String>(friendUsername.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('FriendsCompanion(')..write('id: $id, ')..write('playerId: $playerId, ')..write('friendId: $friendId, ')..write('friendUsername: $friendUsername, ')..write('createdAt: $createdAt')..write(')')).toString();}
}
class $FriendRequestsTable extends FriendRequests with TableInfo<$FriendRequestsTable, FriendRequest>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$FriendRequestsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _senderIdMeta = const VerificationMeta('senderId');
@override
late final GeneratedColumn<String> senderId = GeneratedColumn<String>('sender_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _receiverIdMeta = const VerificationMeta('receiverId');
@override
late final GeneratedColumn<String> receiverId = GeneratedColumn<String>('receiver_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _senderUsernameMeta = const VerificationMeta('senderUsername');
@override
late final GeneratedColumn<String> senderUsername = GeneratedColumn<String>('sender_username', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _statusMeta = const VerificationMeta('status');
@override
late final GeneratedColumn<String> status = GeneratedColumn<String>('status', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant('pending'));
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, senderId, receiverId, senderUsername, status, createdAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'friend_requests';
@override
VerificationContext validateIntegrity(Insertable<FriendRequest> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));} else if (isInserting) {
context.missing(_idMeta);
}
if (data.containsKey('sender_id')) {
context.handle(_senderIdMeta, senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));} else if (isInserting) {
context.missing(_senderIdMeta);
}
if (data.containsKey('receiver_id')) {
context.handle(_receiverIdMeta, receiverId.isAcceptableOrUnknown(data['receiver_id']!, _receiverIdMeta));} else if (isInserting) {
context.missing(_receiverIdMeta);
}
if (data.containsKey('sender_username')) {
context.handle(_senderUsernameMeta, senderUsername.isAcceptableOrUnknown(data['sender_username']!, _senderUsernameMeta));} else if (isInserting) {
context.missing(_senderUsernameMeta);
}
if (data.containsKey('status')) {
context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));}if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override FriendRequest map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return FriendRequest(id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!, senderId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!, receiverId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}receiver_id'])!, senderUsername: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sender_username'])!, status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']), );
}
@override
$FriendRequestsTable createAlias(String alias) {
return $FriendRequestsTable(attachedDatabase, alias);}}class FriendRequest extends DataClass implements Insertable<FriendRequest> 
{
final String id;
final String senderId;
final String receiverId;
final String senderUsername;
final String status;
final DateTime? createdAt;
const FriendRequest({required this.id, required this.senderId, required this.receiverId, required this.senderUsername, required this.status, this.createdAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<String>(id);
map['sender_id'] = Variable<String>(senderId);
map['receiver_id'] = Variable<String>(receiverId);
map['sender_username'] = Variable<String>(senderUsername);
map['status'] = Variable<String>(status);
if (!nullToAbsent || createdAt != null){map['created_at'] = Variable<DateTime>(createdAt);
}return map; 
}
FriendRequestsCompanion toCompanion(bool nullToAbsent) {
return FriendRequestsCompanion(id: Value(id),senderId: Value(senderId),receiverId: Value(receiverId),senderUsername: Value(senderUsername),status: Value(status),createdAt: createdAt == null && nullToAbsent ? const Value.absent() : Value(createdAt),);
}
factory FriendRequest.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return FriendRequest(id: serializer.fromJson<String>(json['id']),senderId: serializer.fromJson<String>(json['senderId']),receiverId: serializer.fromJson<String>(json['receiverId']),senderUsername: serializer.fromJson<String>(json['senderUsername']),status: serializer.fromJson<String>(json['status']),createdAt: serializer.fromJson<DateTime?>(json['createdAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<String>(id),'senderId': serializer.toJson<String>(senderId),'receiverId': serializer.toJson<String>(receiverId),'senderUsername': serializer.toJson<String>(senderUsername),'status': serializer.toJson<String>(status),'createdAt': serializer.toJson<DateTime?>(createdAt),};}FriendRequest copyWith({String? id,String? senderId,String? receiverId,String? senderUsername,String? status,Value<DateTime?> createdAt = const Value.absent()}) => FriendRequest(id: id ?? this.id,senderId: senderId ?? this.senderId,receiverId: receiverId ?? this.receiverId,senderUsername: senderUsername ?? this.senderUsername,status: status ?? this.status,createdAt: createdAt.present ? createdAt.value : this.createdAt,);FriendRequest copyWithCompanion(FriendRequestsCompanion data) {
return FriendRequest(
id: data.id.present ? data.id.value : this.id,senderId: data.senderId.present ? data.senderId.value : this.senderId,receiverId: data.receiverId.present ? data.receiverId.value : this.receiverId,senderUsername: data.senderUsername.present ? data.senderUsername.value : this.senderUsername,status: data.status.present ? data.status.value : this.status,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,);
}
@override
String toString() {return (StringBuffer('FriendRequest(')..write('id: $id, ')..write('senderId: $senderId, ')..write('receiverId: $receiverId, ')..write('senderUsername: $senderUsername, ')..write('status: $status, ')..write('createdAt: $createdAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, senderId, receiverId, senderUsername, status, createdAt);@override
bool operator ==(Object other) => identical(this, other) || (other is FriendRequest && other.id == this.id && other.senderId == this.senderId && other.receiverId == this.receiverId && other.senderUsername == this.senderUsername && other.status == this.status && other.createdAt == this.createdAt);
}class FriendRequestsCompanion extends UpdateCompanion<FriendRequest> {
final Value<String> id;
final Value<String> senderId;
final Value<String> receiverId;
final Value<String> senderUsername;
final Value<String> status;
final Value<DateTime?> createdAt;
final Value<int> rowid;
const FriendRequestsCompanion({this.id = const Value.absent(),this.senderId = const Value.absent(),this.receiverId = const Value.absent(),this.senderUsername = const Value.absent(),this.status = const Value.absent(),this.createdAt = const Value.absent(),this.rowid = const Value.absent(),});
FriendRequestsCompanion.insert({required String id,required String senderId,required String receiverId,required String senderUsername,this.status = const Value.absent(),this.createdAt = const Value.absent(),this.rowid = const Value.absent(),}): id = Value(id), senderId = Value(senderId), receiverId = Value(receiverId), senderUsername = Value(senderUsername);
static Insertable<FriendRequest> custom({Expression<String>? id, 
Expression<String>? senderId, 
Expression<String>? receiverId, 
Expression<String>? senderUsername, 
Expression<String>? status, 
Expression<DateTime>? createdAt, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (senderId != null)'sender_id': senderId,if (receiverId != null)'receiver_id': receiverId,if (senderUsername != null)'sender_username': senderUsername,if (status != null)'status': status,if (createdAt != null)'created_at': createdAt,if (rowid != null)'rowid': rowid,});
}FriendRequestsCompanion copyWith({Value<String>? id, Value<String>? senderId, Value<String>? receiverId, Value<String>? senderUsername, Value<String>? status, Value<DateTime?>? createdAt, Value<int>? rowid}) {
return FriendRequestsCompanion(id: id ?? this.id,senderId: senderId ?? this.senderId,receiverId: receiverId ?? this.receiverId,senderUsername: senderUsername ?? this.senderUsername,status: status ?? this.status,createdAt: createdAt ?? this.createdAt,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<String>(id.value);}
if (senderId.present) {
map['sender_id'] = Variable<String>(senderId.value);}
if (receiverId.present) {
map['receiver_id'] = Variable<String>(receiverId.value);}
if (senderUsername.present) {
map['sender_username'] = Variable<String>(senderUsername.value);}
if (status.present) {
map['status'] = Variable<String>(status.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('FriendRequestsCompanion(')..write('id: $id, ')..write('senderId: $senderId, ')..write('receiverId: $receiverId, ')..write('senderUsername: $senderUsername, ')..write('status: $status, ')..write('createdAt: $createdAt, ')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $PlayersTable players = $PlayersTable(this);
late final $ProgressionsTable progressions = $ProgressionsTable(this);
late final $LevelCompletionsTable levelCompletions = $LevelCompletionsTable(this);
late final $GlobalLevelsTable globalLevels = $GlobalLevelsTable(this);
late final $FriendsTable friends = $FriendsTable(this);
late final $FriendRequestsTable friendRequests = $FriendRequestsTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [players, progressions, levelCompletions, globalLevels, friends, friendRequests];
}
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({Value<int> id,Value<String?> supabaseId,required String username,Value<String?> avatarUrl,Value<int> totalGamesPlayed,Value<int> highscore,Value<int> lives,Value<int> puzzlePieces,Value<int> itemPlusTime,Value<int> itemMoreNumbers,Value<int> itemRevealPath,Value<DateTime?> lastLifeLostAt,Value<DateTime?> updatedAt,});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({Value<int> id,Value<String?> supabaseId,Value<String> username,Value<String?> avatarUrl,Value<int> totalGamesPlayed,Value<int> highscore,Value<int> lives,Value<int> puzzlePieces,Value<int> itemPlusTime,Value<int> itemMoreNumbers,Value<int> itemRevealPath,Value<DateTime?> lastLifeLostAt,Value<DateTime?> updatedAt,});
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
      
ColumnFilters<int> get lives => $composableBuilder(
      column: $table.lives,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get puzzlePieces => $composableBuilder(
      column: $table.puzzlePieces,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get itemPlusTime => $composableBuilder(
      column: $table.itemPlusTime,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get itemMoreNumbers => $composableBuilder(
      column: $table.itemMoreNumbers,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get itemRevealPath => $composableBuilder(
      column: $table.itemRevealPath,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get lastLifeLostAt => $composableBuilder(
      column: $table.lastLifeLostAt,
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
      
ColumnOrderings<int> get lives => $composableBuilder(
      column: $table.lives,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get puzzlePieces => $composableBuilder(
      column: $table.puzzlePieces,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get itemPlusTime => $composableBuilder(
      column: $table.itemPlusTime,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get itemMoreNumbers => $composableBuilder(
      column: $table.itemMoreNumbers,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get itemRevealPath => $composableBuilder(
      column: $table.itemRevealPath,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get lastLifeLostAt => $composableBuilder(
      column: $table.lastLifeLostAt,
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
      
GeneratedColumn<int> get lives => $composableBuilder(
      column: $table.lives,
      builder: (column) => column);
      
GeneratedColumn<int> get puzzlePieces => $composableBuilder(
      column: $table.puzzlePieces,
      builder: (column) => column);
      
GeneratedColumn<int> get itemPlusTime => $composableBuilder(
      column: $table.itemPlusTime,
      builder: (column) => column);
      
GeneratedColumn<int> get itemMoreNumbers => $composableBuilder(
      column: $table.itemMoreNumbers,
      builder: (column) => column);
      
GeneratedColumn<int> get itemRevealPath => $composableBuilder(
      column: $table.itemRevealPath,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get lastLifeLostAt => $composableBuilder(
      column: $table.lastLifeLostAt,
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
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> supabaseId = const Value.absent(),Value<String> username = const Value.absent(),Value<String?> avatarUrl = const Value.absent(),Value<int> totalGamesPlayed = const Value.absent(),Value<int> highscore = const Value.absent(),Value<int> lives = const Value.absent(),Value<int> puzzlePieces = const Value.absent(),Value<int> itemPlusTime = const Value.absent(),Value<int> itemMoreNumbers = const Value.absent(),Value<int> itemRevealPath = const Value.absent(),Value<DateTime?> lastLifeLostAt = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent(),})=> PlayersCompanion(id: id,supabaseId: supabaseId,username: username,avatarUrl: avatarUrl,totalGamesPlayed: totalGamesPlayed,highscore: highscore,lives: lives,puzzlePieces: puzzlePieces,itemPlusTime: itemPlusTime,itemMoreNumbers: itemMoreNumbers,itemRevealPath: itemRevealPath,lastLifeLostAt: lastLifeLostAt,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),Value<String?> supabaseId = const Value.absent(),required String username,Value<String?> avatarUrl = const Value.absent(),Value<int> totalGamesPlayed = const Value.absent(),Value<int> highscore = const Value.absent(),Value<int> lives = const Value.absent(),Value<int> puzzlePieces = const Value.absent(),Value<int> itemPlusTime = const Value.absent(),Value<int> itemMoreNumbers = const Value.absent(),Value<int> itemRevealPath = const Value.absent(),Value<DateTime?> lastLifeLostAt = const Value.absent(),Value<DateTime?> updatedAt = const Value.absent(),})=> PlayersCompanion.insert(id: id,supabaseId: supabaseId,username: username,avatarUrl: avatarUrl,totalGamesPlayed: totalGamesPlayed,highscore: highscore,lives: lives,puzzlePieces: puzzlePieces,itemPlusTime: itemPlusTime,itemMoreNumbers: itemMoreNumbers,itemRevealPath: itemRevealPath,lastLifeLostAt: lastLifeLostAt,updatedAt: updatedAt,),
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
    >;typedef $$LevelCompletionsTableCreateCompanionBuilder = LevelCompletionsCompanion Function({Value<int> id,required String playerSupabaseId,required String worldId,required int levelNumber,required int completionTimeSeconds,Value<DateTime> completedAt,});
typedef $$LevelCompletionsTableUpdateCompanionBuilder = LevelCompletionsCompanion Function({Value<int> id,Value<String> playerSupabaseId,Value<String> worldId,Value<int> levelNumber,Value<int> completionTimeSeconds,Value<DateTime> completedAt,});
class $$LevelCompletionsTableFilterComposer extends Composer<
        _$AppDatabase,
        $LevelCompletionsTable> {
        $$LevelCompletionsTableFilterComposer({
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
      
ColumnFilters<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get completionTimeSeconds => $composableBuilder(
      column: $table.completionTimeSeconds,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$LevelCompletionsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $LevelCompletionsTable> {
        $$LevelCompletionsTableOrderingComposer({
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
      
ColumnOrderings<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get completionTimeSeconds => $composableBuilder(
      column: $table.completionTimeSeconds,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$LevelCompletionsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $LevelCompletionsTable> {
        $$LevelCompletionsTableAnnotationComposer({
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
      
GeneratedColumn<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => column);
      
GeneratedColumn<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => column);
      
GeneratedColumn<int> get completionTimeSeconds => $composableBuilder(
      column: $table.completionTimeSeconds,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt,
      builder: (column) => column);
      
        }
      class $$LevelCompletionsTableTableManager extends RootTableManager    <_$AppDatabase,
    $LevelCompletionsTable,
    LevelCompletion,
    $$LevelCompletionsTableFilterComposer,
    $$LevelCompletionsTableOrderingComposer,
    $$LevelCompletionsTableAnnotationComposer,
    $$LevelCompletionsTableCreateCompanionBuilder,
    $$LevelCompletionsTableUpdateCompanionBuilder,
    (LevelCompletion,BaseReferences<_$AppDatabase,$LevelCompletionsTable,LevelCompletion>),
    LevelCompletion,
    PrefetchHooks Function()
    > {
    $$LevelCompletionsTableTableManager(_$AppDatabase db, $LevelCompletionsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$LevelCompletionsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$LevelCompletionsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$LevelCompletionsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> playerSupabaseId = const Value.absent(),Value<String> worldId = const Value.absent(),Value<int> levelNumber = const Value.absent(),Value<int> completionTimeSeconds = const Value.absent(),Value<DateTime> completedAt = const Value.absent(),})=> LevelCompletionsCompanion(id: id,playerSupabaseId: playerSupabaseId,worldId: worldId,levelNumber: levelNumber,completionTimeSeconds: completionTimeSeconds,completedAt: completedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String playerSupabaseId,required String worldId,required int levelNumber,required int completionTimeSeconds,Value<DateTime> completedAt = const Value.absent(),})=> LevelCompletionsCompanion.insert(id: id,playerSupabaseId: playerSupabaseId,worldId: worldId,levelNumber: levelNumber,completionTimeSeconds: completionTimeSeconds,completedAt: completedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$LevelCompletionsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $LevelCompletionsTable,
    LevelCompletion,
    $$LevelCompletionsTableFilterComposer,
    $$LevelCompletionsTableOrderingComposer,
    $$LevelCompletionsTableAnnotationComposer,
    $$LevelCompletionsTableCreateCompanionBuilder,
    $$LevelCompletionsTableUpdateCompanionBuilder,
    (LevelCompletion,BaseReferences<_$AppDatabase,$LevelCompletionsTable,LevelCompletion>),
    LevelCompletion,
    PrefetchHooks Function()
    >;typedef $$GlobalLevelsTableCreateCompanionBuilder = GlobalLevelsCompanion Function({Value<int> id,required String worldId,required int levelNumber,required String hintsJson,required String wallsJson,required String solutionJson,Value<DateTime> createdAt,});
typedef $$GlobalLevelsTableUpdateCompanionBuilder = GlobalLevelsCompanion Function({Value<int> id,Value<String> worldId,Value<int> levelNumber,Value<String> hintsJson,Value<String> wallsJson,Value<String> solutionJson,Value<DateTime> createdAt,});
class $$GlobalLevelsTableFilterComposer extends Composer<
        _$AppDatabase,
        $GlobalLevelsTable> {
        $$GlobalLevelsTableFilterComposer({
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
      
ColumnFilters<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get hintsJson => $composableBuilder(
      column: $table.hintsJson,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get wallsJson => $composableBuilder(
      column: $table.wallsJson,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get solutionJson => $composableBuilder(
      column: $table.solutionJson,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$GlobalLevelsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $GlobalLevelsTable> {
        $$GlobalLevelsTableOrderingComposer({
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
      
ColumnOrderings<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get hintsJson => $composableBuilder(
      column: $table.hintsJson,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get wallsJson => $composableBuilder(
      column: $table.wallsJson,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get solutionJson => $composableBuilder(
      column: $table.solutionJson,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$GlobalLevelsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $GlobalLevelsTable> {
        $$GlobalLevelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get worldId => $composableBuilder(
      column: $table.worldId,
      builder: (column) => column);
      
GeneratedColumn<int> get levelNumber => $composableBuilder(
      column: $table.levelNumber,
      builder: (column) => column);
      
GeneratedColumn<String> get hintsJson => $composableBuilder(
      column: $table.hintsJson,
      builder: (column) => column);
      
GeneratedColumn<String> get wallsJson => $composableBuilder(
      column: $table.wallsJson,
      builder: (column) => column);
      
GeneratedColumn<String> get solutionJson => $composableBuilder(
      column: $table.solutionJson,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
        }
      class $$GlobalLevelsTableTableManager extends RootTableManager    <_$AppDatabase,
    $GlobalLevelsTable,
    GlobalLevel,
    $$GlobalLevelsTableFilterComposer,
    $$GlobalLevelsTableOrderingComposer,
    $$GlobalLevelsTableAnnotationComposer,
    $$GlobalLevelsTableCreateCompanionBuilder,
    $$GlobalLevelsTableUpdateCompanionBuilder,
    (GlobalLevel,BaseReferences<_$AppDatabase,$GlobalLevelsTable,GlobalLevel>),
    GlobalLevel,
    PrefetchHooks Function()
    > {
    $$GlobalLevelsTableTableManager(_$AppDatabase db, $GlobalLevelsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$GlobalLevelsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$GlobalLevelsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$GlobalLevelsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> worldId = const Value.absent(),Value<int> levelNumber = const Value.absent(),Value<String> hintsJson = const Value.absent(),Value<String> wallsJson = const Value.absent(),Value<String> solutionJson = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),})=> GlobalLevelsCompanion(id: id,worldId: worldId,levelNumber: levelNumber,hintsJson: hintsJson,wallsJson: wallsJson,solutionJson: solutionJson,createdAt: createdAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String worldId,required int levelNumber,required String hintsJson,required String wallsJson,required String solutionJson,Value<DateTime> createdAt = const Value.absent(),})=> GlobalLevelsCompanion.insert(id: id,worldId: worldId,levelNumber: levelNumber,hintsJson: hintsJson,wallsJson: wallsJson,solutionJson: solutionJson,createdAt: createdAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$GlobalLevelsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $GlobalLevelsTable,
    GlobalLevel,
    $$GlobalLevelsTableFilterComposer,
    $$GlobalLevelsTableOrderingComposer,
    $$GlobalLevelsTableAnnotationComposer,
    $$GlobalLevelsTableCreateCompanionBuilder,
    $$GlobalLevelsTableUpdateCompanionBuilder,
    (GlobalLevel,BaseReferences<_$AppDatabase,$GlobalLevelsTable,GlobalLevel>),
    GlobalLevel,
    PrefetchHooks Function()
    >;typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({Value<int> id,required String playerId,required String friendId,required String friendUsername,Value<DateTime> createdAt,});
typedef $$FriendsTableUpdateCompanionBuilder = FriendsCompanion Function({Value<int> id,Value<String> playerId,Value<String> friendId,Value<String> friendUsername,Value<DateTime> createdAt,});
class $$FriendsTableFilterComposer extends Composer<
        _$AppDatabase,
        $FriendsTable> {
        $$FriendsTableFilterComposer({
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
      
ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get friendId => $composableBuilder(
      column: $table.friendId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get friendUsername => $composableBuilder(
      column: $table.friendUsername,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$FriendsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $FriendsTable> {
        $$FriendsTableOrderingComposer({
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
      
ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get friendId => $composableBuilder(
      column: $table.friendId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get friendUsername => $composableBuilder(
      column: $table.friendUsername,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$FriendsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $FriendsTable> {
        $$FriendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get playerId => $composableBuilder(
      column: $table.playerId,
      builder: (column) => column);
      
GeneratedColumn<String> get friendId => $composableBuilder(
      column: $table.friendId,
      builder: (column) => column);
      
GeneratedColumn<String> get friendUsername => $composableBuilder(
      column: $table.friendUsername,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
        }
      class $$FriendsTableTableManager extends RootTableManager    <_$AppDatabase,
    $FriendsTable,
    Friend,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (Friend,BaseReferences<_$AppDatabase,$FriendsTable,Friend>),
    Friend,
    PrefetchHooks Function()
    > {
    $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$FriendsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$FriendsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$FriendsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> playerId = const Value.absent(),Value<String> friendId = const Value.absent(),Value<String> friendUsername = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),})=> FriendsCompanion(id: id,playerId: playerId,friendId: friendId,friendUsername: friendUsername,createdAt: createdAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String playerId,required String friendId,required String friendUsername,Value<DateTime> createdAt = const Value.absent(),})=> FriendsCompanion.insert(id: id,playerId: playerId,friendId: friendId,friendUsername: friendUsername,createdAt: createdAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$FriendsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $FriendsTable,
    Friend,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (Friend,BaseReferences<_$AppDatabase,$FriendsTable,Friend>),
    Friend,
    PrefetchHooks Function()
    >;typedef $$FriendRequestsTableCreateCompanionBuilder = FriendRequestsCompanion Function({required String id,required String senderId,required String receiverId,required String senderUsername,Value<String> status,Value<DateTime?> createdAt,Value<int> rowid,});
typedef $$FriendRequestsTableUpdateCompanionBuilder = FriendRequestsCompanion Function({Value<String> id,Value<String> senderId,Value<String> receiverId,Value<String> senderUsername,Value<String> status,Value<DateTime?> createdAt,Value<int> rowid,});
class $$FriendRequestsTableFilterComposer extends Composer<
        _$AppDatabase,
        $FriendRequestsTable> {
        $$FriendRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get receiverId => $composableBuilder(
      column: $table.receiverId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$FriendRequestsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $FriendRequestsTable> {
        $$FriendRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get receiverId => $composableBuilder(
      column: $table.receiverId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$FriendRequestsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $FriendRequestsTable> {
        $$FriendRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) => column);
      
GeneratedColumn<String> get receiverId => $composableBuilder(
      column: $table.receiverId,
      builder: (column) => column);
      
GeneratedColumn<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername,
      builder: (column) => column);
      
GeneratedColumn<String> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
        }
      class $$FriendRequestsTableTableManager extends RootTableManager    <_$AppDatabase,
    $FriendRequestsTable,
    FriendRequest,
    $$FriendRequestsTableFilterComposer,
    $$FriendRequestsTableOrderingComposer,
    $$FriendRequestsTableAnnotationComposer,
    $$FriendRequestsTableCreateCompanionBuilder,
    $$FriendRequestsTableUpdateCompanionBuilder,
    (FriendRequest,BaseReferences<_$AppDatabase,$FriendRequestsTable,FriendRequest>),
    FriendRequest,
    PrefetchHooks Function()
    > {
    $$FriendRequestsTableTableManager(_$AppDatabase db, $FriendRequestsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$FriendRequestsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$FriendRequestsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$FriendRequestsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<String> id = const Value.absent(),Value<String> senderId = const Value.absent(),Value<String> receiverId = const Value.absent(),Value<String> senderUsername = const Value.absent(),Value<String> status = const Value.absent(),Value<DateTime?> createdAt = const Value.absent(),Value<int> rowid = const Value.absent(),})=> FriendRequestsCompanion(id: id,senderId: senderId,receiverId: receiverId,senderUsername: senderUsername,status: status,createdAt: createdAt,rowid: rowid,),
        createCompanionCallback: ({required String id,required String senderId,required String receiverId,required String senderUsername,Value<String> status = const Value.absent(),Value<DateTime?> createdAt = const Value.absent(),Value<int> rowid = const Value.absent(),})=> FriendRequestsCompanion.insert(id: id,senderId: senderId,receiverId: receiverId,senderUsername: senderUsername,status: status,createdAt: createdAt,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$FriendRequestsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $FriendRequestsTable,
    FriendRequest,
    $$FriendRequestsTableFilterComposer,
    $$FriendRequestsTableOrderingComposer,
    $$FriendRequestsTableAnnotationComposer,
    $$FriendRequestsTableCreateCompanionBuilder,
    $$FriendRequestsTableUpdateCompanionBuilder,
    (FriendRequest,BaseReferences<_$AppDatabase,$FriendRequestsTable,FriendRequest>),
    FriendRequest,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$PlayersTableTableManager get players => $$PlayersTableTableManager(_db, _db.players);
$$ProgressionsTableTableManager get progressions => $$ProgressionsTableTableManager(_db, _db.progressions);
$$LevelCompletionsTableTableManager get levelCompletions => $$LevelCompletionsTableTableManager(_db, _db.levelCompletions);
$$GlobalLevelsTableTableManager get globalLevels => $$GlobalLevelsTableTableManager(_db, _db.globalLevels);
$$FriendsTableTableManager get friends => $$FriendsTableTableManager(_db, _db.friends);
$$FriendRequestsTableTableManager get friendRequests => $$FriendRequestsTableTableManager(_db, _db.friendRequests);
}
