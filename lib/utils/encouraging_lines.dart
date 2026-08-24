import 'dart:math';

class EncouragingLines {
  EncouragingLines._();

  static const List<String> _lines = [
    'Ready to challenge your brain today?',
    "Let's beat your best score!",
    'Every level makes you sharper 🧠',
    'Small steps, big brain gains.',
    'You are on a roll — keep going!',
  ];

  static String getRandom() {
    return _lines[Random().nextInt(_lines.length)];
  }
}