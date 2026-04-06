import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class EffectsService {
  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      // Sound file not found - that's okay
    }
  }

  Future<void> vibrate() async {
    if (!_vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (e) {
      // Vibration not supported
    }
  }

  Future<void> celebrateWin(bool isRecord) async {
    await playWinSound();
    await vibrate();
  }

  void dispose() {
    _player.dispose();
  }
}
