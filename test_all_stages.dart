import 'lib/game_logic.dart';
import 'lib/challenge_stage_config.dart';
import 'lib/difficulty.dart';
import 'dart:math' as math;

void main() {
  print('Starting Challenge Mode Stages tests (7-20)...');
  
  bool allSuccess = true;

  for (int stage = 7; stage <= 20; stage++) {
    print('Testing Stage $stage...');
    try {
      final config = ChallengeStages.getStage(stage);
      
      // Default initial layout sizes based on tileCount
      int _cols = 12; 
      int _rows = 14;
      
      if (config.tileCount <= 40) {
        _cols = 7;
        _rows = 14; 
      } else if (config.tileCount <= 60) {
        _cols = 8;
        _rows = 14;
      } else if (config.tileCount <= 80) {
        _cols = 10;
        _rows = 14;
      } else {
        _cols = 12;
        _rows = 14;
      }

      int requiredTiles = config.tileCount + config.obstacleCount;
      
      // Replicate the dynamic re-sizing logic from ChallengeGameScreen
      int calculateValidSpaces(int rows, int cols, LayoutPattern pattern) {
        int count = 0;
        int centerR = rows ~/ 2;
        int centerC = cols ~/ 2;

        for (int r = 1; r < rows - 1; r++) {
          for (int c = 1; c < cols - 1; c++) {
            bool isValid = true;
            if (pattern == LayoutPattern.pyramid) {
                 isValid = true;
            } else if (pattern == LayoutPattern.diamond) {
                if ((r - centerR).abs() + (c - centerC).abs() > (math.min(rows, cols) ~/ 2) - 1) isValid = false;
            } else if (pattern == LayoutPattern.cross) {
                if ((r - centerR).abs() > 1 && (c - centerC).abs() > 1) isValid = false;
            } else if (pattern == LayoutPattern.ring) {
                int dist = (r - centerR).abs() + (c - centerC).abs();
                if (dist < 2 || dist > 5) isValid = false;
            } else if (pattern == LayoutPattern.border) { 
                 if (r > 2 && r < rows - 3 && c > 2 && c < cols - 3) isValid = false;
            } else if (pattern == LayoutPattern.stripes) {
                if (r % 2 != 0) isValid = false;
            } else if (pattern == LayoutPattern.zigzag) {
                if ((r + c) % 2 != 0) isValid = false;
            } else if (pattern == LayoutPattern.hourglass) {
                if ((r - centerR).abs() < (c - centerC).abs()) isValid = false;
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
          
          if (_cols > 20 || _rows > 30) {
             print('  [Warning] Max grid size reached for stage $stage');
             break;
          }
      }
      
      print('  Calculated grid: $_cols x $_rows, Valid Spaces: $validSpaces, Required: $requiredTiles');

      // Create logic instance using the adjusted rows and cols
      final logic = SichuanLogic(
        rows: _rows,
        cols: _cols,
        tileCount: config.tileCount,
        obstacleCount: config.obstacleCount,
        pattern: config.pattern,
        difficulty: Difficulty.challenge,
      );
      
      final board = logic.generateBoard();
      
      int count = 0;
      int blocks = 0;
      for (var b in board) {
        if (b.isNotEmpty && b != 'BLOCK') count++;
        if (b == 'BLOCK') blocks++;
      }
      print('  Success! Tiles: $count (Expected: ${config.tileCount}), Blocks: $blocks (Expected: ${config.obstacleCount})');
      
      if (count != config.tileCount || blocks != config.obstacleCount) {
         print('  [ERROR] Mismatch in generated counts!');
         allSuccess = false;
      }
    } catch (e) {
      print('  [ERROR] Exception on Stage $stage: $e');
      allSuccess = false;
    }
  }
  
  if (allSuccess) {
    print('\nAll stages 7-20 passed successfully!');
  } else {
    print('\nSome stages failed.');
  }
}
