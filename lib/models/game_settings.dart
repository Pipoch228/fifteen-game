import 'game_enums.dart';

class GameSettings {
  GameMode mode;
  GameTheme theme;
  bool soundEnabled;
  bool vibrationEnabled;

  GameSettings({
    this.mode = GameMode.fourByFour,
    this.theme = GameTheme.landscapes,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  GameSettings copyWith({
    GameMode? mode,
    GameTheme? theme,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return GameSettings(
      mode: mode ?? this.mode,
      theme: theme ?? this.theme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
