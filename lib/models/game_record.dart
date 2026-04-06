class GameRecord {
  final int moves;
  final int seconds;
  final DateTime date;

  GameRecord({
    required this.moves,
    required this.seconds,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'moves': moves,
        'seconds': seconds,
        'date': date.toIso8601String(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        moves: json['moves'] as int,
        seconds: json['seconds'] as int,
        date: DateTime.parse(json['date'] as String),
      );

  bool isBetterThan(GameRecord other) {
    if (seconds != other.seconds) {
      return seconds < other.seconds;
    }
    return moves < other.moves;
  }
}
