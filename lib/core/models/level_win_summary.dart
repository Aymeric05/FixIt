import 'package:equatable/equatable.dart';

class FriendRankEntry extends Equatable {
  final String playerId;
  final String username;
  final int timeSeconds;
  final int rank;

  const FriendRankEntry({
    required this.playerId,
    required this.username,
    required this.timeSeconds,
    required this.rank,
  });

  @override
  List<Object?> get props => [playerId, username, timeSeconds, rank];
}

class LevelWinSummary extends Equatable {
  final int globalCompletionCount;
  final int friendCompletionCount;
  final int globalAverageSeconds;
  final int worldRecordSeconds;
  final String worldRecordHolder;
  final double? globalPercentile; // e.g. 0.2 for top 20%
  final List<FriendRankEntry> friendsMiniLeaderboard; // Up to 3 entries: above, user, below

  const LevelWinSummary({
    required this.globalCompletionCount,
    required this.friendCompletionCount,
    required this.globalAverageSeconds,
    required this.worldRecordSeconds,
    required this.worldRecordHolder,
    this.globalPercentile,
    required this.friendsMiniLeaderboard,
  });

  @override
  List<Object?> get props => [
        globalCompletionCount,
        friendCompletionCount,
        globalAverageSeconds,
        worldRecordSeconds,
        worldRecordHolder,
        globalPercentile,
        friendsMiniLeaderboard,
      ];
}
