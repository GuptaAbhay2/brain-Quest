class StarCalculator {
  StarCalculator._();

  static int forNumberTap({
    required int maxNumber,
    required int timeSeconds,
    required int wrongTaps,
  }) {
    final parTime = (maxNumber * 0.9).ceil();

    if (wrongTaps == 0 && timeSeconds <= parTime) return 3;
    if (wrongTaps <= 2 && timeSeconds <= (parTime * 1.6).ceil()) return 2;
    return 1;
  }

  static int forWordBuilder({
    required int timerSeconds,
    required int timeTakenSeconds,
    required int wrongTaps,
  }) {
    final remainingRatio = 1 - (timeTakenSeconds / timerSeconds);

    if (wrongTaps == 0 && remainingRatio >= 0.4) return 3;
    if (wrongTaps <= 2 && remainingRatio >= 0.15) return 2;
    return 1;
  }

  static int forMathTrueFalse({
    required int totalQuestions,
    required int correctCount,
    required int wrongCount,
  }) {
    if (wrongCount == 0) return 3;
    final accuracy = correctCount / totalQuestions;
    if (accuracy >= 0.75) return 2;
    return 1;
  }

  static int forImageNaming({
    required int wordLength,
    required int timeSeconds,
    required int wrongTaps,
  }) {
    final parTime = (wordLength * 2.5).ceil();

    if (wrongTaps == 0 && timeSeconds <= parTime) return 3;
    if (wrongTaps <= 2 && timeSeconds <= (parTime * 1.6).ceil()) return 2;
    return 1;
  }
}