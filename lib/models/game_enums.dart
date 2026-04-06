enum GameMode {
  threeByThree(3, '3×3', 8),
  fourByFour(4, '4×4', 15),
  fiveByFive(5, '5×5', 24),
  sixBySix(6, '6×6', 35);

  final int size;
  final String label;
  final int emptyValue;

  const GameMode(this.size, this.label, this.emptyValue);

  int get totalTiles => size * size;
}

enum GameTheme {
  wood('Дерево', 'wood'),
  marble('Мрамор', 'marble'),
  neon('Неон', 'neon'),
  blackWhite('ЧБ', 'bw'),
  landscapes('Пейзажи', 'landscapes'),
  nature('Природа', 'nature'),
  abstract('Абстракция', 'abstract'),
  animals('Животные', 'animals');

  final String label;
  final String value;

  const GameTheme(this.label, this.value);

  bool get isTexture => this == GameTheme.wood || 
                        this == GameTheme.marble || 
                        this == GameTheme.neon || 
                        this == GameTheme.blackWhite;

  String? get unsplashQuery {
    switch (this) {
      case GameTheme.landscapes:
        return 'landscape';
      case GameTheme.nature:
        return 'nature';
      case GameTheme.abstract:
        return 'abstract';
      case GameTheme.animals:
        return 'animals';
      default:
        return null;
    }
  }
}
