import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_type.dart';
import '../../providers/level_provider.dart';
import '../../providers/stats_provider.dart';
import '../../services/audio_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/level_config_generator.dart';
import '../../utils/star_calculator.dart';
import '../result_screen.dart';

class _LetterCard {
  final int id;
  final String letter;
  bool isUsed;
  _LetterCard({required this.id, required this.letter, this.isUsed = false});
}

class ImageNamingGameScreen extends StatefulWidget {
  final int levelNumber;

  const ImageNamingGameScreen({super.key, required this.levelNumber});

  @override
  State<ImageNamingGameScreen> createState() => _ImageNamingGameScreenState();
}

class _ImageNamingGameScreenState extends State<ImageNamingGameScreen> {
  late final String _targetWord;
  late final String _emoji;
  late final String? _imageAsset;
  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _cardIdCounter = 0;

  int _elapsedSeconds = 0;
  int _nextIndex = 0;
  int _wrongTapCount = 0;
  int? _wrongFlashCardId;
  late List<_LetterCard> _cards;

  @override
  void initState() {
    super.initState();
    final config = LevelConfigGenerator.getConfig(widget.levelNumber).imageConfig!;
    _targetWord = config.answer.toUpperCase();
    _emoji = config.emoji;
    _imageAsset = config.imageAsset;
    _cards = _generateCards();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<_LetterCard> _generateCards() {
    final letters = _targetWord.split('');
    final cards = <_LetterCard>[
      for (final letter in letters) _LetterCard(id: _cardIdCounter++, letter: letter),
    ];

    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const distractorCount = 8;
    for (int i = 0; i < distractorCount; i++) {
      final randomLetter = alphabet[_random.nextInt(alphabet.length)];
      cards.add(_LetterCard(id: _cardIdCounter++, letter: randomLetter));
    }

    cards.shuffle(_random);
    return cards;
  }

  void _handleCardTap(_LetterCard card) {
    if (card.isUsed) return;
    final requiredLetter = _targetWord[_nextIndex];

    if (card.letter == requiredLetter) {
      AudioService.instance.playTap();
      setState(() {
        card.isUsed = true;
        _nextIndex++;
      });
      if (_nextIndex >= _targetWord.length) {
        _onComplete();
      }
    } else {
      AudioService.instance.playError();
      setState(() {
        _wrongTapCount++;
        _wrongFlashCardId = card.id;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _wrongFlashCardId = null);
      });
    }
  }

  Future<void> _onComplete() async {
    _ticker?.cancel();
    _stopwatch.stop();
    final timeTaken = _stopwatch.elapsed.inSeconds;

    final stars = StarCalculator.forImageNaming(
      wordLength: _targetWord.length,
      timeSeconds: timeTaken,
      wrongTaps: _wrongTapCount,
    );

    final levelProvider = context.read<LevelProvider>();
    final statsProvider = context.read<StatsProvider>();
    final previousBestStars = levelProvider.getLevelProgress(widget.levelNumber)?.starsEarned ?? 0;

    await levelProvider.completeLevel(
      levelNumber: widget.levelNumber,
      starsEarned: stars,
      timeTakenSeconds: timeTaken,
      wrongTaps: _wrongTapCount,
    );
    await statsProvider.recordGameSession(starsEarned: stars, timeSpentSeconds: timeTaken);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          levelNumber: widget.levelNumber,
          gameType: GameType.imageNaming,
          starsEarned: stars,
          timeTakenSeconds: timeTaken,
          wrongTaps: _wrongTapCount,
          isNewBest: stars > previousBestStars,
          extraInfoLabel: 'Answer',
          extraInfoValue: _targetWord,
          playAgainBuilder: (_) => ImageNamingGameScreen(levelNumber: widget.levelNumber),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${_elapsedSeconds}s', style: AppTextStyles.body),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 4),
              Text('$_wrongTapCount', style: AppTextStyles.body.copyWith(color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: _imageAsset != null
          ? ClipOval(
              child: Image.asset(_imageAsset!, width: 134, height: 134, fit: BoxFit.cover),
            )
          : Text(_emoji, style: const TextStyle(fontSize: 64)),
    );
  }

  Widget _buildWordSlots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_targetWord.length, (index) {
        final isRevealed = index < _nextIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36,
          height: 42,
          decoration: BoxDecoration(
            color: isRevealed ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isRevealed ? AppColors.primary : AppColors.textMuted.withOpacity(0.4),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            isRevealed ? _targetWord[index] : '',
            style: AppTextStyles.levelNumber.copyWith(color: AppColors.primary),
          ),
        );
      }),
    );
  }

  Widget _buildLetterCard(_LetterCard card) {
    final isWrongFlash = _wrongFlashCardId == card.id;

    return IgnorePointer(
      ignoring: card.isUsed,
      child: GestureDetector(
        onTap: () => _handleCardTap(card),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: card.isUsed
                ? AppColors.surfaceLight.withOpacity(0.3)
                : isWrongFlash
                    ? AppColors.error
                    : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: card.isUsed
                  ? AppColors.textMuted.withOpacity(0.2)
                  : isWrongFlash
                      ? AppColors.error
                      : AppColors.secondary.withOpacity(0.4),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            card.letter,
            style: AppTextStyles.levelNumber.copyWith(
              color: card.isUsed ? AppColors.textMuted.withOpacity(0.4) : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.levelNumber}')),
      body: Column(
        children: [
          _buildStatsBar(),
          const Divider(height: 1, color: AppColors.surfaceLight),
          const SizedBox(height: 20),
          _buildImageDisplay(),
          const SizedBox(height: 24),
          _buildWordSlots(),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: _cards.map(_buildLetterCard).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}