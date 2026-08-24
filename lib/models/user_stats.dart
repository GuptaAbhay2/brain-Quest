import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 1)
class UserStats extends HiveObject {
  @HiveField(0)
  int totalStars;

  @HiveField(1)
  int currentStreak;

  @HiveField(2)
  DateTime? lastPlayedDate;

  @HiveField(3)
  int totalTimeSpentSeconds;

  @HiveField(4)
  int totalScore;

  UserStats({
    this.totalStars = 0,
    this.currentStreak = 0,
    this.lastPlayedDate,
    this.totalTimeSpentSeconds = 0,
    this.totalScore = 0,
  });
}