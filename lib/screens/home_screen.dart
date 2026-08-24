import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/encouraging_lines.dart';
import '../widgets/game_summary_card.dart';
import '../widgets/level_circle_tile.dart';

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
      body: Consumer<LevelProvider>(
        builder: (context, levelProvider, _) {
          final levels = levelProvider.levels;
          final currentLevel = levelProvider.currentLevelNumber;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back! 👋', style: AppTextStyles.heading1),
                    const SizedBox(height: 4),
                    Text(_encouragingLine, style: AppTextStyles.body),
                  ],
                ),
              ),
              GameSummaryCard(
                totalStars: levelProvider.totalStarsEarned,
                maxStars: AppConstants.totalLevels * 3,
                currentLevel: currentLevel,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isCurrent = level.levelNumber == currentLevel;

                    return LevelCircleTile(
                      progress: level,
                      isCurrent: isCurrent,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Level ${level.levelNumber} tapped — game screen aage banayenge'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
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