import 'package:hive_flutter/hive_flutter.dart';
import '../models/level_progress.dart';
import '../models/user_stats.dart';
import '../utils/constants.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  late Box<LevelProgress> _levelProgressBox;
  late Box<UserStats> _userStatsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(LevelProgressAdapter());
    Hive.registerAdapter(UserStatsAdapter());

    _levelProgressBox = await Hive.openBox<LevelProgress>(
      AppConstants.levelProgressBoxName,
    );
    _userStatsBox = await Hive.openBox<UserStats>(
      AppConstants.userStatsBoxName,
    );

    await _seedLevelsIfNeeded();
  }

  Future<void> _seedLevelsIfNeeded() async {
    if (_levelProgressBox.isEmpty) {
      for (int i = 1; i <= AppConstants.totalLevels; i++) {
        final progress = LevelProgress(
          levelNumber: i,
          isUnlocked: i == 1,
        );
        await _levelProgressBox.put(i, progress);
      }
    }
  }

  // ---------- LEVEL PROGRESS ----------

  LevelProgress? getLevelProgress(int levelNumber) {
    return _levelProgressBox.get(levelNumber);
  }

  List<LevelProgress> getAllLevelProgress() {
    final list = _levelProgressBox.values.toList();
    list.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    return list;
  }

  Future<void> saveLevelProgress(LevelProgress progress) async {
    await _levelProgressBox.put(progress.levelNumber, progress);
  }

  // ---------- USER STATS ----------

  UserStats getUserStats() {
    return _userStatsBox.get(AppConstants.userStatsKey) ?? UserStats();
  }

  Future<void> saveUserStats(UserStats stats) async {
    await _userStatsBox.put(AppConstants.userStatsKey, stats);
  }
}
