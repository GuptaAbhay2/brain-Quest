import 'package:flutter/material.dart';
import '../models/game_type.dart';
import '../utils/app_colors.dart';
import '../utils/app_page_route.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/level_config_generator.dart';
import 'games/number_tap_game_screen.dart';
import 'games/word_builder_game_screen.dart';
import 'games/math_true_false_game_screen.dart';
import 'games/image_naming_game_screen.dart';

class ResultScreen extends StatefulWidget {
  final int levelNumber;
  final GameType gameType;
  final int starsEarned;
  final int timeTakenSeconds;
  final int wrongTaps;
  final bool isNewBest;
  final String? extraInfoLabel;
  final String? extraInfoValue;
  final WidgetBuilder playAgainBuilder;

  const ResultScreen({
    super.key,
    required this.levelNumber,
    required this.gameType,
    required this.starsEarned,
    required this.timeTakenSeconds,
    required this.wrongTaps,
    required this.isNewBest,
    this.extraInfoLabel,
    this.extraInfoValue,
    required this.playAgainBuilder,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isFinalLevel => widget.levelNumber == AppConstants.totalLevels;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _starAnimation(int index) {
    final start = index * 0.15;
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: widget.playAgainBuilder),
    );
  }

  void _goToNextLevel() {
    final nextLevelNumber = widget.levelNumber + 1;
    final config = LevelConfigGenerator.getConfig(nextLevelNumber);
    final gameType = LevelConfigGenerator.getGameType(config);

    Widget screen;
    switch (gameType) {
      case GameType.numberTap:
        screen = NumberTapGameScreen(levelNumber: nextLevelNumber);
        break;
      case GameType.wordBuilder:
        screen = WordBuilderGameScreen(levelNumber: nextLevelNumber);
        break;
      case GameType.mathTrueFalse:
        screen = MathTrueFalseGameScreen(levelNumber: nextLevelNumber);
        break;
      case GameType.imageNaming:
        screen = ImageNamingGameScreen(levelNumber: nextLevelNumber);
        break;
    }

    Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                '${widget.gameType.displayName} • Level ${widget.levelNumber}',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
              _buildGlowBadge(),
              const SizedBox(height: 28),
              Text(
                _isFinalLevel ? 'Brain Quest Complete! 🏆' : 'Level Complete!',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              if (_isFinalLevel) ...[
                const SizedBox(height: 6),
                Text(
                  "You've cleared all ${AppConstants.totalLevels} levels — true Brain Master!",
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              _buildStars(),
              if (widget.isNewBest) ...[
                const SizedBox(height: 14),
                _buildNewBestChip(),
              ],
              const SizedBox(height: 28),
              _buildStatsCard(),
              const Spacer(),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowBadge() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Icon(
        _isFinalLevel ? Icons.military_tech_rounded : Icons.emoji_events_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < widget.starsEarned;
        return ScaleTransition(
          scale: _starAnimation(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.star,
              size: 60,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNewBestChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.star.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.star.withOpacity(0.6)),
      ),
      child: Text(
        '🔥 New Best!',
        style: AppTextStyles.body.copyWith(color: AppColors.star, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = <Widget>[
      _statItem(Icons.timer_outlined, '${widget.timeTakenSeconds}s', 'Time'),
      _statItem(Icons.close_rounded, '${widget.wrongTaps}', 'Wrong Taps'),
    ];

    if (widget.extraInfoLabel != null && widget.extraInfoValue != null) {
      stats.add(_statItem(Icons.info_outline_rounded, widget.extraInfoValue!, widget.extraInfoLabel!));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats,
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButtons() {
    final hasNextLevel = !_isFinalLevel;

    if (hasNextLevel) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _goToNextLevel,
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              label: Text('Next Level', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goHome,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.textMuted.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Home', style: AppTextStyles.body),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: _playAgain,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.textMuted.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Play Again', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _playAgain,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Play Again', style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _goHome,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.textMuted.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Home', style: AppTextStyles.body),
          ),
        ),
      ],
    );
  }
}