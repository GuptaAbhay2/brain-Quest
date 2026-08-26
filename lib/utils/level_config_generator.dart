import 'dart:math';
import '../models/game_type.dart';
import '../models/game_configs.dart';
import 'constants.dart';

class LevelConfigGenerator {
  LevelConfigGenerator._();

  // Fixed seed — taaki app restart hone pe bhi levels same rahein, random na badlein
  static final Random _seededRandom = Random(1907);

  static final List<LevelConfig> _allConfigs = _generateAll();
  static List<LevelConfig> get allConfigs => _allConfigs;

  static LevelConfig getConfig(int levelNumber) {
    return _allConfigs.firstWhere((c) => c.levelNumber == levelNumber);
  }

  static GameType getGameType(LevelConfig config) {
    if (config.numberTapConfig != null) return GameType.numberTap;
    if (config.wordBuilderConfig != null) return GameType.wordBuilder;
    if (config.mathConfig != null) return GameType.mathTrueFalse;
    return GameType.imageNaming;
  }

  static const List<String> _wordBank = [
    'LION', 'TIGER', 'KITE', 'STAR', 'MOON',
    'HAPPY', 'SMILE', 'MUSIC', 'DANCE', 'CLOUD',
    'FRIEND', 'GARDEN', 'PLANET', 'PENCIL', 'WINDOW',
    'ELEPHANT', 'BUTTERFLY', 'MOUNTAIN', 'DINOSAUR', 'RAINBOW',
    'BAHUBALI', 'CRICKET', 'PAINTING', 'TREASURE', 'JOURNEY',
  ];

  static const List<Map<String, String>> _imageBank = [
    {'answer': 'LION', 'emoji': '🦁'},
    {'answer': 'ELEPHANT', 'emoji': '🐘'},
    {'answer': 'MONKEY', 'emoji': '🐒'},
    {'answer': 'RABBIT', 'emoji': '🐰'},
    {'answer': 'TIGER', 'emoji': '🐯'},
    {'answer': 'PANDA', 'emoji': '🐼'},
    {'answer': 'GIRAFFE', 'emoji': '🦒'},
    {'answer': 'PENGUIN', 'emoji': '🐧'},
    {'answer': 'DOLPHIN', 'emoji': '🐬'},
    {'answer': 'BUTTERFLY', 'emoji': '🦋'},
    {'answer': 'APPLE', 'emoji': '🍎'},
    {'answer': 'ROCKET', 'emoji': '🚀'},
    {'answer': 'GUITAR', 'emoji': '🎸'},
    {'answer': 'BICYCLE', 'emoji': '🚲'},
  ];

  static List<LevelConfig> _generateAll() {
    // "Shuffled bag" trick: 4 types ko group me shuffle karte hain (10 baar)
    // isse 40 levels me exactly 10-10 har type ke milte hain, phir bhi order random/mixed lagta hai
    const basePattern = [
      GameType.numberTap,
      GameType.wordBuilder,
      GameType.mathTrueFalse,
      GameType.imageNaming,
    ];

    final List<GameType> typeSequence = [];
    while (typeSequence.length < AppConstants.totalLevels) {
      final shuffled = List<GameType>.from(basePattern)..shuffle(_seededRandom);
      typeSequence.addAll(shuffled);
    }
    final finalSequence = typeSequence.sublist(0, AppConstants.totalLevels);

    int wordIndex = 0;
    int imageIndex = 0;
    final List<LevelConfig> configs = [];

    for (int i = 1; i <= AppConstants.totalLevels; i++) {
      final type = finalSequence[i - 1];

      switch (type) {
        case GameType.numberTap:
          configs.add(LevelConfig(
            levelNumber: i,
            numberTapConfig: NumberTapConfig(maxNumber: _numberTapMax(i)),
          ));
          break;

        case GameType.wordBuilder:
          final word = _wordBank[wordIndex % _wordBank.length];
          wordIndex++;
          configs.add(LevelConfig(
            levelNumber: i,
            wordBuilderConfig: WordBuilderConfig(word: word, timerSeconds: _wordTimer(i)),
          ));
          break;

        case GameType.mathTrueFalse:
          configs.add(LevelConfig(
            levelNumber: i,
            mathConfig: MathTrueFalseConfig(
              timerSeconds: _mathTimer(i),
              maxOperand: _mathMaxOperand(i),
            ),
          ));
          break;

        case GameType.imageNaming:
          final item = _imageBank[imageIndex % _imageBank.length];
          imageIndex++;
          configs.add(LevelConfig(
            levelNumber: i,
            imageConfig: ImageNamingConfig(answer: item['answer']!, emoji: item['emoji']!),
          ));
          break;
      }
    }

    return configs;
  }

  // Difficulty scaling functions — level jitna aage, utna hard

  static int _numberTapMax(int level) {
    final base = 15 + (level * 1.6).round();
    final jitter = _seededRandom.nextInt(11) - 5; // -5 se +5 tak variation
    return (base + jitter).clamp(10, 90);
  }

  static int _wordTimer(int level) {
    if (level <= 14) return 60;
    if (level <= 27) return 30;
    return 20;
  }

  static int _mathTimer(int level) {
    if (level <= 14) return 20;
    if (level <= 27) return 15;
    return 10;
  }

  static int _mathMaxOperand(int level) {
    final base = 10 + (level * 1.0).round();
    return base.clamp(10, 50);
  }
}