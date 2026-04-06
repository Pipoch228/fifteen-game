import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_enums.dart';
import '../models/game_record.dart';
import '../services/storage_service.dart';

class GameState extends ChangeNotifier {
  final StorageService _storage;
  
  GameMode _mode;
  int _emptyPosition = 0;
  late List<int> _tiles;
  int _moves = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isCompleted = false;
  bool _isNewRecord = false;
  String? _currentImageUrl;

  GameState(this._storage) : _mode = _storage.getMode() {
    _initGame();
  }

  GameMode get mode => _mode;
  List<int> get tiles => _tiles;
  int get moves => _moves;
  int get seconds => _seconds;
  bool get isCompleted => _isCompleted;
  bool get isNewRecord => _isNewRecord;
  String? get currentImageUrl => _currentImageUrl;

  void setMode(GameMode mode) {
    _mode = mode;
    _storage.saveMode(mode);
    _initGame();
    notifyListeners();
  }

  void _initGame() {
    _stopTimer();
    _moves = 0;
    _seconds = 0;
    _isCompleted = false;
    _isNewRecord = false;
    _currentImageUrl = null;
    _tiles = List.generate(_mode.totalTiles, (i) => i);
    _shuffle();
    _emptyPosition = _tiles.indexOf(0);
  }

  void _shuffle() {
    final random = Random();
    for (int i = _tiles.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      if (_tiles[j] != 0 && _tiles[i] != 0) {
        _swap(i, j);
      }
    }
    if (_isSolved()) {
      _shuffle();
    }
  }

  void _swap(int i, int j) {
    final temp = _tiles[i];
    _tiles[i] = _tiles[j];
    _tiles[j] = temp;
  }

  bool canMove(int index) {
    final row = index ~/ _mode.size;
    final col = index % _mode.size;
    final emptyRow = _emptyPosition ~/ _mode.size;
    final emptyCol = _emptyPosition % _mode.size;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
           (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void move(int index) {
    if (_isCompleted || !canMove(index)) return;

    _swap(index, _emptyPosition);
    _emptyPosition = index;
    _moves++;

    if (_timer == null) {
      _startTimer();
    }

    if (_isSolved()) {
      _completeGame();
    }

    notifyListeners();
  }

  bool _isSolved() {
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return _tiles.last == 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _completeGame() async {
    _stopTimer();
    _isCompleted = true;
    
    final record = GameRecord(
      moves: _moves,
      seconds: _seconds,
      date: DateTime.now(),
    );
    
    _isNewRecord = await _storage.saveRecord(_mode, record);
    notifyListeners();
  }

  void restart() {
    _initGame();
    notifyListeners();
  }

  void setImageUrl(String url) {
    _currentImageUrl = url;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
