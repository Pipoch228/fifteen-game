import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_record.dart';
import '../models/game_enums.dart';

class StorageService {
  static const _settingsKey = 'game_settings';
  static const _recordsPrefix = 'records_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveMode(GameMode mode) async {
    await _prefs.setString('${_settingsKey}_mode', mode.name);
  }

  GameMode getMode() {
    final name = _prefs.getString('${_settingsKey}_mode');
    return GameMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => GameMode.fourByFour,
    );
  }

  Future<void> saveTheme(GameTheme theme) async {
    await _prefs.setString('${_settingsKey}_theme', theme.name);
  }

  GameTheme getTheme() {
    final name = _prefs.getString('${_settingsKey}_theme');
    return GameTheme.values.firstWhere(
      (e) => e.name == name,
      orElse: () => GameTheme.landscapes,
    );
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs.setBool('${_settingsKey}_sound', enabled);
  }

  bool getSoundEnabled() {
    return _prefs.getBool('${_settingsKey}_sound') ?? true;
  }

  Future<void> saveVibrationEnabled(bool enabled) async {
    await _prefs.setBool('${_settingsKey}_vibration', enabled);
  }

  bool getVibrationEnabled() {
    return _prefs.getBool('${_settingsKey}_vibration') ?? true;
  }

  Future<List<GameRecord>> getRecords(GameMode mode) async {
    final json = _prefs.getString('${_recordsPrefix}${mode.name}');
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => GameRecord.fromJson(e)).toList();
  }

  Future<bool> saveRecord(GameMode mode, GameRecord record) async {
    final records = await getRecords(mode);
    records.add(record);
    records.sort((a, b) {
      if (a.seconds != b.seconds) {
        return a.seconds.compareTo(b.seconds);
      }
      return a.moves.compareTo(b.moves);
    });

    final top10 = records.take(10).toList();
    await _prefs.setString(
      '${_recordsPrefix}${mode.name}',
      jsonEncode(top10.map((e) => e.toJson()).toList()),
    );

    return top10.contains(record);
  }

  Future<void> clearRecords(GameMode mode) async {
    await _prefs.remove('${_recordsPrefix}${mode.name}');
  }
}
