import 'package:flutter/material.dart';
import '../models/level_progress.dart';
import '../services/database_service.dart';

class LevelProvider extends ChangeNotifier {
  List<LevelProgress> _levels = [];
  List<LevelProgress> get levels => _levels;

  LevelProvider() {
    loadLevels();
  }

  void loadLevels() {
    _levels = DatabaseService.instance.getAllLevelProgress();
    notifyListeners();
  }

  // Pehla incomplete level hi "current level" hai
  int get currentLevelNumber {
    if (_levels.isEmpty) return 1;
    final firstIncomplete = _levels.firstWhere(
      (level) => !level.isCompleted,
      orElse: () => _levels.last,
    );
    return firstIncomplete.levelNumber;
  }

  int get totalStarsEarned {
    return _levels.fold(0, (sum, level) => sum + level.starsEarned);
  }

  LevelProgress? getLevelProgress(int levelNumber) {
    try {
      return _levels.firstWhere((l) => l.levelNumber == levelNumber);
    } catch (_) {
      return null;
    }
  }

  Future<void> completeLevel({
    required int levelNumber,
    required int starsEarned,
    required int timeTakenSeconds,
    required int wrongTaps,
  }) async {
    final index = _levels.indexWhere((l) => l.levelNumber == levelNumber);
    if (index == -1) return;

    final level = _levels[index];
    level.isCompleted = true;

    // Sabse acha stars hamesha rakho, kam kabhi mat karo
    if (starsEarned > level.starsEarned) {
      level.starsEarned = starsEarned;
    }

    // Best time track karo (self-challenge ke liye)
    if (level.bestTimeSeconds == null || timeTakenSeconds < level.bestTimeSeconds!) {
      level.bestTimeSeconds = timeTakenSeconds;
      level.wrongTaps = wrongTaps;
    }

    await DatabaseService.instance.saveLevelProgress(level);

    // Agla level unlock karo
    final nextLevelNumber = levelNumber + 1;
    final nextIndex = _levels.indexWhere((l) => l.levelNumber == nextLevelNumber);
    if (nextIndex != -1 && !_levels[nextIndex].isUnlocked) {
      _levels[nextIndex].isUnlocked = true;
      await DatabaseService.instance.saveLevelProgress(_levels[nextIndex]);
    }

    notifyListeners();
  }
}