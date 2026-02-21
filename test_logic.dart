import 'lib/game_logic.dart';
import 'lib/challenge_stage_config.dart';
import 'lib/difficulty.dart';

void main() {
  print('Starting Stage 7 generation test...');
  final config = ChallengeStages.getStage(7);
  
  // 실제 앱에서 동작하는 것과 동일하게 _calculateValidSpaces와 가변 격자를 적용해봅니다.
  int _cols = 8;
  int _rows = 14;
  int requiredTiles = config.tileCount + config.obstacleCount;
  
  // 내부 로직 복사
  int calculateValidSpaces(int rows, int cols, LayoutPattern pattern) {
    int count = 0;
    int centerR = rows ~/ 2;
    int centerC = cols ~/ 2;

    for (int r = 1; r < rows - 1; r++) {
      for (int c = 1; c < cols - 1; c++) {
        bool isValid = true;
        if (pattern == LayoutPattern.stripes) {
            if (r % 2 != 0) isValid = false;
        }
        if (isValid) count++;
      }
    }
    return count;
  }
  
  int validSpaces = calculateValidSpaces(_rows, _cols, config.pattern);
  while (validSpaces < requiredTiles) {
      _cols += 2;
      if (_cols > _rows) {
          _rows += 2;
      }
      validSpaces = calculateValidSpaces(_rows, _cols, config.pattern);
      if (_cols > 20 || _rows > 30) break;
  }
  
  print('Calculated grid: $_cols x $_rows (Valid spaces: $validSpaces for $requiredTiles tiles)');

  final logic = SichuanLogic(
    rows: _rows,
    cols: _cols,
    tileCount: config.tileCount,
    obstacleCount: config.obstacleCount,
    pattern: config.pattern,
    difficulty: Difficulty.challenge,
  );
  
  try {
    final board = logic.generateBoard();
    print('Generation successful!');
    int count = 0;
    for (var b in board) {
      if (b.isNotEmpty && b != 'BLOCK') count++;
    }
    print('Tiles generated: $count');
  } catch (e) {
    print('Error: $e');
  }
}
