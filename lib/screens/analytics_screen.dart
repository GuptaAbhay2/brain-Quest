import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/streak_card.dart';
import '../widgets/stat_grid_card.dart';
import '../widgets/player_rank_card.dart';
import '../widgets/level_mastery_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer2<StatsProvider, LevelProvider>(
        builder: (context, statsProvider, levelProvider, _) {
          final levels = levelProvider.levels;
          final levelsCompleted = levels.where((l) => l.isCompleted).length;
          final threeStarCount = levels.where((l) => l.starsEarned == 3).length;
          final twoStarCount = levels.where((l) => l.starsEarned == 2).length;
          final oneStarCount = levels.where((l) => l.starsEarned == 1).length;
          final maxStars = AppConstants.totalLevels * 3;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'Player Stats',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlayerRankCard(
                          totalStars: levelProvider.totalStarsEarned,
                          maxStars: maxStars,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StreakCard(streakDays: statsProvider.currentStreak),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LevelMasteryCard(
                  totalLevels: AppConstants.totalLevels,
                  levelsCompleted: levelsCompleted,
                  threeStarCount: threeStarCount,
                  twoStarCount: twoStarCount,
                  oneStarCount: oneStarCount,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatGridCard(
                          icon: Icons.timer_rounded,
                          iconColor: AppColors.secondary,
                          value: Formatters.formatDuration(statsProvider.totalTimeSpentSeconds),
                          label: 'Total Time',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatGridCard(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.primary,
                          value: '${statsProvider.totalScore}',
                          label: 'Total Score',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}