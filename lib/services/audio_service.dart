import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playTap() async {
    try {
      await _player.play(AssetSource('sounds/tap.mp3'));
    } catch (_) 
    }
  }

  Future<void> playError() async {
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (_) {}
  }
}
