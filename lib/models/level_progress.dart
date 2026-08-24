import 'package:hive/hive.dart';

part 'level_progress.g.dart';

@HiveType(typeId: 0)
class LevelProgress extends HiveObject {
  @HiveField(0)
  final int levelNumber;

  @HiveField(1)
  bool isUnlocked;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int starsEarned; // best stars achieved (0-3)

  @HiveField(4)
  int? bestTimeSeconds; // best time in seconds, mainly number-tap self-challenge ke liye

  @HiveField(5)
  int wrongTaps; // best attempt ke wrong taps

  LevelProgress({
    required this.levelNumber,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestTimeSeconds,
    this.wrongTaps = 0,
  });
}