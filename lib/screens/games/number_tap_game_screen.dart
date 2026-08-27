import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_type.dart';
import '../../providers/level_provider.dart';
import '../../providers/stats_provider.dart';
import '../../services/audio_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_page_route.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/dialogs.dart';
import '../../utils/level_config_generator.dart';
import '../../utils/star_calculator.dart';
import '../result_screen.dart';

class NumberTapGameScreen extends StatefulWidget {
  final int levelNumber;

  const NumberTapGameScreen({super.key, required this.levelNumber});

  @override
  State<NumberTapGameScreen> createState() => _NumberTapGameScreenState();
}

class _NumberTapGameScreenState extends State<NumberTapGameScreen> {
  late final int _maxNumber;
  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();
  Timer? _ticker;

  int _nextExpected = 1;
  final Set<int> _tappedNumbers = {};
  int _wrongTapCount = 0;
  int? _wrongFlashNumber;

  List<Offset>? _positions;
  double? _positionsWidth;
  double _contentHeight = 0;

  @override
  void initState() {
    super.initState();
    final config = LevelConfigGenerator.getConfig(widget.levelNumber);
    _maxNumber = config.numberTapConfig!.maxNumber;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  double _circleDiameter() {
    if (_maxNumber <= 25) return 50;
    if (_maxNumber <= 45) return 42;
    if (_maxNumber <= 65) return 36;
    return 32;
  }

  void _generatePositions(double areaWidth, double diameter) {
    const spacing = 10.0;
    final cellSize = diameter + spacing;
    final cols = (areaWidth / cellSize).floor().clamp(1, _maxNumber);
    final rows = (_maxNumber / cols).ceil();

    final cells = <List<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        cells.add([r, c]);
      }
    }
    cells.shuffle(_random);

    final jitterMax = spacing * 0.5;
    final positions = <Offset>[];
    for (int i = 0; i < _maxNumber; i++) {
      final cell = cells[i];
      final baseX = cell[1] * cellSize;
      final baseY = cell[0] * cellSize;
      final jitterX = _random.nextDouble() * jitterMax - (jitterMax / 2);
      final jitterY = _random.nextDouble() * jitterMax - (jitterMax / 2);
      positions.add(Offset(baseX + jitterX, baseY + jitterY));
    }

    _positions = positions;
    _contentHeight = rows * cellSize + diameter + spacing;
  }

  void _handleTap(int number) {
    if (number == _nextExpected) {
      AudioService.instance.playTap();
      setState(() {
        _tappedNumbers.add(number);
        _nextExpected++;
      });
      if (_nextExpected > _maxNumber) {
        _onGameComplete();
      }
    } else {
      AudioService.instance.playError();
      setState(() {
        _wrongTapCount++;
        _wrongFlashNumber = number;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _wrongFlashNumber = null);
      });
    }
  }

  Future<void> _onGameComplete() async {
    _ticker?.cancel();
    _stopwatch.stop();
    final timeSeconds = (_stopwatch.elapsedMilliseconds / 1000).round();

    final stars = StarCalculator.forNumberTap(
      maxNumber: _maxNumber,
      timeSeconds: timeSeconds,
      wrongTaps: _wrongTapCount,
    );

    final levelProvider = context.read<LevelProvider>();
    final statsProvider = context.read<StatsProvider>();
    final previousBestStars = levelProvider.getLevelProgress(widget.levelNumber)?.starsEarned ?? 0;

    await levelProvider.completeLevel(
      levelNumber: widget.levelNumber,
      starsEarned: stars,
      timeTakenSeconds: timeSeconds,
      wrongTaps: _wrongTapCount,
    );
    await statsProvider.recordGameSession(
      starsEarned: stars,
      timeSpentSeconds: timeSeconds,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppPageRoute(
        builder: (_) => ResultScreen(
          levelNumber: widget.levelNumber,
          gameType: GameType.numberTap,
          starsEarned: stars,
          timeTakenSeconds: timeSeconds,
          wrongTaps: _wrongTapCount,
          isNewBest: stars > previousBestStars,
          playAgainBuilder: (_) => NumberTapGameScreen(levelNumber: widget.levelNumber),
        ),
      ),
    );
  }

  Widget _buildRangeHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'Find numbers 1-$_maxNumber',
        textAlign: TextAlign.center,
        style: AppTextStyles.heading2.copyWith(fontSize: 19),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statChip(Icons.timer_outlined, '${_stopwatch.elapsed.inSeconds}s'),
          _findChip(),
          _statChip(Icons.close_rounded, '$_wrongTapCount', color: AppColors.error),
        ],
      ),
    );
  }

  Widget _findChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Text(
        'Find: $_nextExpected',
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.body.copyWith(color: color ?? AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildNumberBubble(int number, Offset position, double diameter) {
    final isTapped = _tappedNumbers.contains(number);
    final isWrongFlash = _wrongFlashNumber == number;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        ignoring: isTapped,
        child: GestureDetector(
          onTap: () => _handleTap(number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTapped
                  ? AppColors.success.withOpacity(0.2)
                  : isWrongFlash
                      ? AppColors.error
                      : AppColors.surfaceLight,
              border: Border.all(
                color: isTapped
                    ? AppColors.success
                    : isWrongFlash
                        ? AppColors.error
                        : AppColors.primary.withOpacity(0.4),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: isTapped
                ? Icon(Icons.check_rounded, color: AppColors.success, size: diameter * 0.5)
                : Text(
                    '$number',
                    style: AppTextStyles.levelNumber.copyWith(fontSize: diameter * 0.36),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _circleDiameter();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => showExitConfirmDialog(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'level-${widget.levelNumber}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.2),
                    border: Border.all(color: AppColors.currentLevelGlow, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.levelNumber}',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('Level ${widget.levelNumber}'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildRangeHeader(),
          _buildStatsBar(),
          const Divider(height: 1, color: AppColors.surfaceLight),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (_positions == null || _positionsWidth != constraints.maxWidth) {
                  _positionsWidth = constraints.maxWidth;
                  _generatePositions(constraints.maxWidth, diameter);
                }

                final height = _contentHeight < constraints.maxHeight
                    ? constraints.maxHeight
                    : _contentHeight;

                return SingleChildScrollView(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: height,
                    child: Stack(
                      children: List.generate(_maxNumber, (i) {
                        final number = i + 1;
                        return _buildNumberBubble(number, _positions![i], diameter);
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}