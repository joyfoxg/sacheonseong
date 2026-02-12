enum Difficulty {
  easy,
  normal,
  hard
}

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return '초급';
      case Difficulty.normal:
        return '중급';
      case Difficulty.hard:
        return '고급';
    }
  }
}
