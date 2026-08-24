import 'game_type.dart';

class GameResult {
  final int levelNumber;
  final GameType gameType;
  final bool isSuccess;
  final int starsEarned;
  final int timeTakenSeconds;
  final int wrongTaps;

  GameResult({
    required this.levelNumber,
    required this.gameType,
    required this.isSuccess,
    required this.starsEarned,
    required this.timeTakenSeconds,
    required this.wrongTaps,
  });
}