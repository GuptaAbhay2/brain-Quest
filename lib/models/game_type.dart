enum GameType {
  numberTap,
  wordBuilder,
  mathTrueFalse,
  imageNaming,
}

extension GameTypeX on GameType {
  String get displayName {
    switch (this) {
      case GameType.numberTap:
        return 'Number Tap';
      case GameType.wordBuilder:
        return 'Word Builder';
      case GameType.mathTrueFalse:
        return 'Math True/False';
      case GameType.imageNaming:
        return 'Image Naming';
    }
  }
}