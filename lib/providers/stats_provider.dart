import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  UserStats _stats = UserStats();
  UserStats get stats => _stats;

  int get totalStars => _stats.totalStars;
  int get currentStreak => _stats.currentStreak;
  int get totalTimeSpentSeconds => _stats.totalTimeSpentSeconds;
  int get totalScore => _stats.totalScore;

  StatsProvider() {
    loadStats();
  }

  void loadStats() {
    _stats = DatabaseService.instance.getUserStats();
    notifyListeners();
  }

  Future<void> recordGameSession({
    required int starsEarned,
    required int timeSpentSeconds,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_stats.lastPlayedDate == null) {
      _stats.currentStreak = 1;
    } else {
      final lastDate = DateTime(
        _stats.lastPlayedDate!.year,
        _stats.lastPlayedDate!.month,
        _stats.lastPlayedDate!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        _stats.currentStreak += 1;
      } else if (difference > 1) {
        _stats.currentStreak = 1;
      }
      // difference == 0 matlab aaj already khela hai, streak same rahega
    }

    _stats.lastPlayedDate = now;
    _stats.totalTimeSpentSeconds += timeSpentSeconds;
    _stats.totalScore += starsEarned;

    // total stars hamesha fresh levels data se recompute karo
    final allLevels = DatabaseService.instance.getAllLevelProgress();
    _stats.totalStars = allLevels.fold(0, (sum, level) => sum + level.starsEarned);

    await DatabaseService.instance.saveUserStats(_stats);
    notifyListeners();
  }
}