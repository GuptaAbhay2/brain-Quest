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
import '../../utils/constants.dart';
import '../../utils/level_config_generator.dart';
import '../../utils/star_calculator.dart';
import '../result_screen.dart';

class _MathQuestion {
  final int operandA;
  final int operandB;
  final String operatorSymbol;
  final int displayedAnswer;
  final bool isCorrect;

  _MathQuestion({
    required this.operandA,
    required this.operandB,
    required this.operatorSymbol,
    required this.displayedAnswer,
    required this.isCorrect,
  });
}

class MathTrueFalseGameScreen extends StatefulWidget {
  final int levelNumber;

  const MathTrueFalseGameScreen({super.key, required this.levelNumber});

  @override
  State<MathTrueFalseGameScreen> createState() => _MathTrueFalseGameScreenState();
}

class _MathTrueFalseGameScreenState extends State<MathTrueFalseGameScreen> {
  late final int _timerSeconds;
  late final int _maxOperand;
  final Random _random = Random();
  final Stopwatch _totalStopwatch = Stopwatch();
  Timer? _ticker;

  late List<_MathQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _remainingSeconds = 0;
  bool _answered = false;
  bool? _lastAnswerCorrect;

  @override
  void initState() {
    super.initState();
    final config = LevelConfigGenerator.getConfig(widget.levelNumber).mathConfig!;
    _timerSeconds = config.timerSeconds;
    _maxOperand = config.maxOperand;
    _questions = List.generate(
      AppConstants.mathQuestionsPerLevel,
      (_) => _generateQuestion(_maxOperand),
    );
    _totalStopwatch.start();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  _MathQuestion _generateQuestion(int maxOperand) {
    const operators = ['+', '-', '×'];
    final operatorSymbol = operators[_random.nextInt(operators.length)];

    int a = _random.nextInt(maxOperand) + 1;
    int b = _random.nextInt(maxOperand) + 1;
    int actualAnswer;

    switch (operatorSymbol) {
      case '-':
        if (b > a) {
          final temp = a;
          a = b;
          b = temp;
        }
        actualAnswer = a - b;
        break;
      case '×':
        a = _random.nextInt(min(maxOperand, 12)) + 1;
        b = _random.nextInt(min(maxOperand, 12)) + 1;
        actualAnswer = a * b;
        break;
      default:
        actualAnswer = a + b;
    }

    final showCorrect = _random.nextBool();
    int displayedAnswer = actualAnswer;

    if (!showCorrect) {
      final offset = _random.nextInt(5) + 1;
      displayedAnswer = actualAnswer + offset;
      if (_random.nextBool() && actualAnswer - offset >= 0) {
        displayedAnswer = actualAnswer - offset;
      }
    }

    return _MathQuestion(
      operandA: a,
      operandB: b,
      operatorSymbol: operatorSymbol,
      displayedAnswer: displayedAnswer,
      isCorrect: displayedAnswer == actualAnswer,
    );
  }

  void _startQuestionTimer() {
    _remainingSeconds = _timerSeconds;
    _answered = false;
    _lastAnswerCorrect = null;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleAnswer(bool userSaysTrue) {
    if (_answered) return;
    _ticker?.cancel();

    final question = _questions[_currentIndex];
    final isUserCorrect = userSaysTrue == question.isCorrect;

    setState(() {
      _answered = true;
      _lastAnswerCorrect = isUserCorrect;
      if (isUserCorrect) {
        _correctCount++;
        AudioService.instance.playTap();
      } else {
        _wrongCount++;
        AudioService.instance.playError();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), _goToNextQuestion);
  }

  void _handleTimeout() {
    if (_answered) return;
    AudioService.instance.playError();
    setState(() {
      _answered = true;
      _lastAnswerCorrect = false;
      _wrongCount++;
    });
    Future.delayed(const Duration(milliseconds: 500), _goToNextQuestion);
  }

  void _goToNextQuestion() {
    if (!mounted) return;
    if (_currentIndex >= _questions.length - 1) {
      _onQuizComplete();
    } else {
      setState(() => _currentIndex++);
      _startQuestionTimer();
    }
  }

  Future<void> _onQuizComplete() async {
    _totalStopwatch.stop();
    final timeTaken = _totalStopwatch.elapsed.inSeconds;

    final stars = StarCalculator.forMathTrueFalse(
      totalQuestions: _questions.length,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
    );

    final levelProvider = context.read<LevelProvider>();
    final statsProvider = context.read<StatsProvider>();
    final previousBestStars = levelProvider.getLevelProgress(widget.levelNumber)?.starsEarned ?? 0;

    await levelProvider.completeLevel(
      levelNumber: widget.levelNumber,
      starsEarned: stars,
      timeTakenSeconds: timeTaken,
      wrongTaps: _wrongCount,
    );
    await statsProvider.recordGameSession(starsEarned: stars, timeSpentSeconds: timeTaken);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          levelNumber: widget.levelNumber,
          gameType: GameType.mathTrueFalse,
          starsEarned: stars,
          timeTakenSeconds: timeTaken,
          wrongTaps: _wrongCount,
          isNewBest: stars > previousBestStars,
          extraInfoLabel: 'Correct',
          extraInfoValue: '$_correctCount/${_questions.length}',
          playAgainBuilder: (_) => MathTrueFalseGameScreen(levelNumber: widget.levelNumber),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final isLow = _remainingSeconds <= 3;
    final timerColor = isLow ? AppColors.error : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, size: 18, color: timerColor),
              const SizedBox(width: 4),
              Text('${_remainingSeconds}s',
                  style: AppTextStyles.body.copyWith(color: timerColor, fontWeight: FontWeight.w700)),
            ],
          ),
          Text('Question ${_currentIndex + 1}/${_questions.length}', style: AppTextStyles.body),
          Row(
            children: [
              const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 4),
              Text('$_wrongCount', style: AppTextStyles.body.copyWith(color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquationCard(_MathQuestion question) {
    Color borderColor = AppColors.primary.withOpacity(0.4);
    Color bgColor = AppColors.surfaceLight;

    if (_answered) {
      borderColor = _lastAnswerCorrect == true ? AppColors.success : AppColors.error;
      bgColor = borderColor.withOpacity(0.15);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      child: Text(
        '${question.operandA} ${question.operatorSymbol} ${question.operandB} = ${question.displayedAnswer}',
        textAlign: TextAlign.center,
        style: AppTextStyles.heading1.copyWith(fontSize: 30),
      ),
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: _answered ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.15),
            foregroundColor: color,
            side: BorderSide(color: color, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(label, style: AppTextStyles.button.copyWith(color: color, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.levelNumber}')),
      body: Column(
        children: [
          _buildStatsBar(),
          const Divider(height: 1, color: AppColors.surfaceLight),
          const Spacer(),
          _buildEquationCard(question),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Row(
              children: [
                _buildAnswerButton(label: 'TRUE', color: AppColors.success, onTap: () => _handleAnswer(true)),
                _buildAnswerButton(label: 'FALSE', color: AppColors.error, onTap: () => _handleAnswer(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}