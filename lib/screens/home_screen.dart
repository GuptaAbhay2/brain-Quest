import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/chapter_banner.dart';
import '../widgets/game_summary_card.dart';
import '../widgets/level_path_tile.dart';
import 'games/number_tap_game_screen.dart';
import 'games/word_builder_game_screen.dart';
import 'games/math_true_false_game_screen.dart';
import 'games/image_naming_game_screen.dart';

class _ChapterInfo {
  final String title;
  final IconData icon;
  final Color color;
  final int startLevel;
  final int endLevel;

  const _ChapterInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.startLevel,
    required this.endLevel,
  });
}

const List<_ChapterInfo> _chapters = [
  _ChapterInfo(
    title: 'Getting Started',
    icon: Icons.spa_rounded,
    color: AppColors.secondary,
    startLevel: 1,
    endLevel: 10,
  ),
  _ChapterInfo(
    title: 'Rising Challenge',
    icon: Icons.trending_up_rounded,
    color: AppColors.primary,
    startLevel: 11,
    endLevel: 20,
  ),
  _ChapterInfo(
    title: 'Brain Storm',
    icon: Icons.bolt_rounded,
    color: AppColors.star,
    startLevel: 21,
    endLevel: 30,
  ),
  _ChapterInfo(
    title: 'Master Mind',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFF6B9D),
    startLevel: 31,
    endLevel: 40,
  ),
];

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

  _ChapterInfo? _chapterStartingAt(int levelNumber) {
    for (final chapter in _chapters) {
      if (chapter.startLevel == levelNumber) return chapter;
    }
    return null;
  }

  void _openLevel(BuildContext context, int levelNumber) {
    final config = LevelConfigGenerator.getConfig(levelNumber);
    final gameType = LevelConfigGenerator.getGameType(config);

    Widget screen;
    switch (gameType) {
      case GameType.numberTap:
        screen = NumberTapGameScreen(levelNumber: levelNumber);
        break;
      case GameType.wordBuilder:
        screen = WordBuilderGameScreen(levelNumber: levelNumber);
        break;
      case GameType.mathTrueFalse:
        screen = MathTrueFalseGameScreen(levelNumber: levelNumber);
        break;
      case GameType.imageNaming:
        screen = ImageNamingGameScreen(levelNumber: levelNumber);
        break;
    }

    Navigator.of(context).push(AppPageRoute(builder: (_) => screen));
  }

  Widget _glowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
        ),
      ),
    );
  }

 Widget _buildHeader(int streak) {
    return Container(
      // Margin hata diya taaki ye edge-to-edge full width rahe
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Image jaisa dark solid background
        // Bottom pe ek subtle divider border taaki content se alag dikhe
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [ AppColors.primary,AppColors.textMuted],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
              ],
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'BRAIN QUEST', 
            style: AppTextStyles.heading2.copyWith(
              fontSize: 15, 
              letterSpacing: 1.3,
            ),
          ),
          const Spacer(),
          _streakPill(streak),
        ],
      ),
    );
  }

  Widget _streakPill(int streak) {
    const streakColor = Color(0xFFFF6B35);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: streakColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: streakColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text('$streak', style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: streakColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(top: -110, right: -70, child: _glowOrb(AppColors.primary, 260)),
            Positioned(top: -50, left: -100, child: _glowOrb(AppColors.secondary, 220)),
            SafeArea(
              child: Consumer2<LevelProvider, StatsProvider>(
                builder: (context, levelProvider, statsProvider, _) {
                  final levels = levelProvider.levels;
                  final currentLevel = levelProvider.currentLevelNumber;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(statsProvider.currentStreak),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 32),
                          itemCount: levels.length,
                          itemBuilder: (context, index) {
                            final level = levels[index];
                            final isCurrent = level.levelNumber == currentLevel;
                            final previousCompleted =
                                index == 0 ? false : levels[index - 1].isCompleted;
                            final chapter = _chapterStartingAt(level.levelNumber);

                            double lockedOpacity = 1.0;
                            if (!level.isUnlocked) {
                              final distance = level.levelNumber - currentLevel;
                              lockedOpacity = (1.0 - (distance * 0.15)).clamp(0.25, 1.0);
                            }

                            return Column(
                              children: [
                                if (chapter != null)
                                  ChapterBanner(
                                    title: chapter.title,
                                    icon: chapter.icon,
                                    color: chapter.color,
                                    startLevel: chapter.startLevel,
                                    endLevel: chapter.endLevel,
                                    isLocked: !level.isUnlocked,
                                    isFirst: index == 0,
                                  ),
                                LevelPathTile(
                                  progress: level,
                                  isCurrent: isCurrent,
                                  showTopConnector: index != 0 && chapter == null,
                                  topConnectorBright: previousCompleted,
                                  statsOnLeft: index.isEven,
                                  lockedOpacity: lockedOpacity,
                                  onTap: () => _openLevel(context, level.levelNumber),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}