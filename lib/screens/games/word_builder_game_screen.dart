import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/stats_provider.dart';
import '../../services/audio_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/level_config_generator.dart';
import '../../utils/star_calculator.dart';

class _LetterCard {
  final int id;
  final String letter;
  bool isUsed;
  _LetterCard({required this.id, required this.letter, this.isUsed = false});
}

class WordBuilderGameScreen extends StatefulWidget {
  final int levelNumber;

  const WordBuilderGameScreen({super.key, required this.levelNumber});

  @override
  State<WordBuilderGameScreen> createState() => _WordBuilderGameScreenState();
}

class _WordBuilderGameScreenState extends State<WordBuilderGameScreen> {
  late final String _targetWord;
  late final int _timerSeconds;
  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _cardIdCounter = 0;

  int _remainingSeconds = 0;
  int _nextIndex = 0;
  int _wrongTapCount = 0;
  int? _wrongFlashCardId;
  List<_LetterCard> _cards = [];

  @override
  void initState() {
    super.initState();
    final config = LevelConfigGenerator.getConfig(widget.levelNumber).wordBuilderConfig!;
    _targetWord = config.word.toUpperCase();
    _timerSeconds = config.timerSeconds;
    _startNewAttempt();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startNewAttempt() {
    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();
    _nextIndex = 0;
    _wrongTapCount = 0;
    _remainingSeconds = _timerSeconds;
    _cards = _generateCards();

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final remaining = (_timerSeconds - _stopwatch.elapsed.inSeconds).clamp(0, _timerSeconds);
      setState(() => _remainingSeconds = remaining);
      if (remaining <= 0) {
        timer.cancel();
        _stopwatch.stop();
        _onTimeUp();
      }
    });

    if (mounted) setState(() {});
  }

  // distractorCount tweak kar sakta hai — jitna zyada, utna hard/mixed lagega
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
        _onWordComplete();
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

  Future<void> _onWordComplete() async {
    _ticker?.cancel();
    _stopwatch.stop();
    final timeTaken = _stopwatch.elapsed.inSeconds;

    final stars = StarCalculator.forWordBuilder(
      timerSeconds: _timerSeconds,
      timeTakenSeconds: timeTaken,
      wrongTaps: _wrongTapCount,
    );

    final levelProvider = context.read<LevelProvider>();
    final statsProvider = context.read<StatsProvider>();

    await levelProvider.completeLevel(
      levelNumber: widget.levelNumber,
      starsEarned: stars,
      timeTakenSeconds: timeTaken,
      wrongTaps: _wrongTapCount,
    );
    await statsProvider.recordGameSession(starsEarned: stars, timeSpentSeconds: timeTaken);

    if (!mounted) return;
    _showResultDialog(stars, timeTaken);
  }

  void _onTimeUp() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Time's Up! ⏱️", style: AppTextStyles.heading2, textAlign: TextAlign.center),
        content: Text(
          'Time khatam ho gaya. Ek aur try kar!',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Home', style: AppTextStyles.body),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewAttempt();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Replay', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(int stars, int timeSeconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Level Complete! 🎉', style: AppTextStyles.heading2, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.star,
                  size: 40,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Time: ${timeSeconds}s', style: AppTextStyles.body),
            Text('Wrong Taps: $_wrongTapCount', style: AppTextStyles.body),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Home', style: AppTextStyles.body),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewAttempt();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Play Again', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerChip() {
    final isLow = _remainingSeconds <= 5;
    final color = isLow ? AppColors.error : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Text('${_remainingSeconds}s',
              style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerChip(),
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

  Widget _buildWordDisplay() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_targetWord.length, (index) {
        final isFilled = index < _nextIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 46,
          decoration: BoxDecoration(
            color: isFilled ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.textMuted.withOpacity(0.4),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _targetWord[index],
            style: AppTextStyles.levelNumber.copyWith(
              color: isFilled ? AppColors.primary : AppColors.textPrimary,
            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildWordDisplay(),
          ),
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