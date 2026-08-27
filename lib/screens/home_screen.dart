import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_type.dart';
import '../providers/level_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_page_route.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/encouraging_lines.dart';
import '../utils/level_config_generator.dart';
import '../widgets/game_summary_card.dart';
import '../widgets/level_path_tile.dart';
import 'games/number_tap_game_screen.dart';
import 'games/word_builder_game_screen.dart';
import 'games/math_true_false_game_screen.dart';
import 'games/image_naming_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String _encouragingLine;

  @override
  void initState() {
    super.initState();
    _encouragingLine = EncouragingLines.getRandom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brain Quest')),
      body: Consumer2<LevelProvider, StatsProvider>(
        builder: (context, levelProvider, statsProvider, _) {
          final levels = levelProvider.levels;
          final currentLevel = levelProvider.currentLevelNumber;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back! 👋',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _encouragingLine,
                      style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GameSummaryCard(
                totalStars: levelProvider.totalStarsEarned,
                maxStars: AppConstants.totalLevels * 3,
                currentLevel: currentLevel,
                currentStreak: statsProvider.currentStreak,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isCurrent = level.levelNumber == currentLevel;
                    final previousCompleted =
                        index == 0 ? false : levels[index - 1].isCompleted;

                    double lockedOpacity = 1.0;
                    if (!level.isUnlocked) {
                      final distance = level.levelNumber - currentLevel;
                      lockedOpacity = (1.0 - (distance * 0.15)).clamp(0.25, 1.0);
                    }

                    return LevelPathTile(
                      progress: level,
                      isCurrent: isCurrent,
                      showTopConnector: index != 0,
                      topConnectorBright: previousCompleted,
                      statsOnLeft: index.isEven,
                      lockedOpacity: lockedOpacity,
                      onTap: () {
                        final config = LevelConfigGenerator.getConfig(level.levelNumber);
                        final gameType = LevelConfigGenerator.getGameType(config);

                        Widget screen;
                        switch (gameType) {
                          case GameType.numberTap:
                            screen = NumberTapGameScreen(levelNumber: level.levelNumber);
                            break;
                          case GameType.wordBuilder:
                            screen = WordBuilderGameScreen(levelNumber: level.levelNumber);
                            break;
                          case GameType.mathTrueFalse:
                            screen = MathTrueFalseGameScreen(levelNumber: level.levelNumber);
                            break;
                          case GameType.imageNaming:
                            screen = ImageNamingGameScreen(levelNumber: level.levelNumber);
                            break;
                        }

                        Navigator.of(context).push(AppPageRoute(builder: (_) => screen));
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}