import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/streak_card.dart';
import '../widgets/stat_grid_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer2<StatsProvider, LevelProvider>(
        builder: (context, statsProvider, levelProvider, _) {
          final levelsCompleted = levelProvider.levels.where((l) => l.isCompleted).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Your Progress', style: AppTextStyles.heading1),
                ),
                const SizedBox(height: 20),
                StreakCard(streakDays: statsProvider.currentStreak),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25,
                    children: [
                      StatGridCard(
                        icon: Icons.timer_rounded,
                        iconColor: AppColors.secondary,
                        value: Formatters.formatDuration(statsProvider.totalTimeSpentSeconds),
                        label: 'Total Time',
                      ),
                      StatGridCard(
                        icon: Icons.emoji_events_rounded,
                        iconColor: AppColors.star,
                        value: '${statsProvider.totalScore}',
                        label: 'Total Score',
                      ),
                      StatGridCard(
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.success,
                        value: '$levelsCompleted',
                        label: 'Levels Completed',
                      ),
                      StatGridCard(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.star,
                        value: '${levelProvider.totalStarsEarned}',
                        label: 'Total Stars',
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