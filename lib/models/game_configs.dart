class NumberTapConfig {
  final int maxNumber;
  const NumberTapConfig({required this.maxNumber});
}

class WordBuilderConfig {
  final String word;
  final int timerSeconds;
  const WordBuilderConfig({required this.word, required this.timerSeconds});
}

class MathTrueFalseConfig {
  final int timerSeconds;
  final int maxOperand; // numbers is range ke andar honge (e.g. 1-10, 1-50)
  const MathTrueFalseConfig({required this.timerSeconds, required this.maxOperand});
}

class ImageNamingConfig {
  final String answer;
  final String emoji;
  final String? imageAsset; // baad me apni image use karni ho to yaha path daal dena
  const ImageNamingConfig({required this.answer, required this.emoji, this.imageAsset});
}

class LevelConfig {
  final int levelNumber;
  final NumberTapConfig? numberTapConfig;
  final WordBuilderConfig? wordBuilderConfig;
  final MathTrueFalseConfig? mathConfig;
  final ImageNamingConfig? imageConfig;

  const LevelConfig({
    required this.levelNumber,
    this.numberTapConfig,
    this.wordBuilderConfig,
    this.mathConfig,
    this.imageConfig,
  });
}