import 'dart:collection';
import 'dart:math';

class SichuanLogic {
  // 사천성 보드 크기 (10x14 등 짝수 권장)
  // 유니코드 마작 타일 리스트
  // 1. 수패 (Number Tiles: 만, 통, 삭) - 약 130종 이상
  static const List<String> numbers = [
    'b_tile_00_00.png', 'b_tile_00_01.png', 'b_tile_00_03.png', 'b_tile_00_04.png', 'b_tile_00_05.png', 'b_tile_00_06.png', 'b_tile_00_07.png', 'b_tile_00_08.png', 'b_tile_00_10.png', 'b_tile_00_11.png', 'b_tile_00_12.png', 'b_tile_00_13.png',
    'b_tile_01_00.png', 'b_tile_01_01.png', 'b_tile_01_02.png', 'b_tile_01_03.png', 'b_tile_01_04.png', 'b_tile_01_08.png', 'b_tile_01_09.png', 'b_tile_01_10.png', 'b_tile_01_11.png', 'b_tile_01_12.png', 'b_tile_01_13.png',
    'b_tile_02_03.png', 'b_tile_02_04.png', 'b_tile_02_05.png', 'b_tile_02_06.png', 'b_tile_02_07.png', 'b_tile_02_08.png', 'b_tile_02_09.png', 'b_tile_02_11.png',
    'b_tile_04_00.png', 'b_tile_04_01.png', 'b_tile_04_02.png', 'b_tile_04_03.png', 'b_tile_04_07.png', 'b_tile_04_08.png', 'b_tile_04_09.png', 'b_tile_04_10.png', 'b_tile_04_11.png', 'b_tile_04_12.png', 'b_tile_04_13.png',
    'b_tile_05_00.png', 'b_tile_05_02.png', 'b_tile_05_03.png', 'b_tile_05_04.png', 'b_tile_05_05.png', 'b_tile_05_07.png', 'b_tile_05_09.png', 'b_tile_05_10.png', 'b_tile_05_13.png',
    'b_tile_06_00.png', 'b_tile_06_01.png', 'b_tile_06_02.png', 'b_tile_06_03.png', 'b_tile_06_04.png', 'b_tile_06_05.png', 'b_tile_06_08.png', 'b_tile_06_09.png', 'b_tile_06_11.png', 'b_tile_06_12.png',
    'b_tile_07_00.png', 'b_tile_07_01.png', 'b_tile_07_02.png', 'b_tile_07_03.png', 'b_tile_07_04.png', 'b_tile_07_05.png', 'b_tile_07_06.png', 'b_tile_07_07.png', 'b_tile_07_08.png', 'b_tile_07_09.png', 'b_tile_07_10.png', 'b_tile_07_12.png', 'b_tile_07_13.png',
    'b_tile_08_00.png', 'b_tile_08_01.png', 'b_tile_08_02.png', 'b_tile_08_04.png', 'b_tile_08_07.png', 'b_tile_08_08.png', 'b_tile_08_09.png', 'b_tile_08_12.png', 'b_tile_08_13.png',
    'b_tile_09_00.png', 'b_tile_09_01.png', 'b_tile_09_02.png', 'b_tile_09_04.png', 'b_tile_09_05.png', 'b_tile_09_06.png', 'b_tile_09_07.png', 'b_tile_09_08.png', 'b_tile_09_09.png', 'b_tile_09_12.png', 'b_tile_09_13.png',
    'b_tile_10_00.png', 'b_tile_10_01.png', 'b_tile_10_02.png', 'b_tile_10_03.png', 'b_tile_10_04.png', 'b_tile_10_05.png', 'b_tile_10_06.png', 'b_tile_10_08.png', 'b_tile_10_09.png', 'b_tile_10_10.png', 'b_tile_10_11.png',
  ];

  // 2. 자패 (Honor Tiles: 동남서북, 중발백)
  static const List<String> honors = [
    'b_tile_03_03.png', 'b_tile_03_05.png', 'b_tile_03_07.png', 'b_tile_03_08.png', 'b_tile_03_09.png', 'b_tile_03_10.png', 'b_tile_03_11.png', 'b_tile_03_12.png',
    'd_tile_00_00.png', 'd_tile_00_01.png', 'd_tile_00_02.png', 'd_tile_00_03.png', 'd_tile_00_04.png', 'd_tile_00_05.png', 'd_tile_00_06.png', 'd_tile_00_07.png', 'd_tile_00_08.png', 'd_tile_00_09.png', 'd_tile_00_13.png',
    'd_tile_01_05.png', 'd_tile_01_06.png', 'd_tile_01_08.png', 'd_tile_01_09.png', 'd_tile_01_10.png', 'd_tile_01_13.png',
    'd_tile_02_01.png', 'd_tile_02_02.png', 'd_tile_02_03.png', 'd_tile_02_04.png', 'd_tile_02_05.png', 'd_tile_02_06.png', 'd_tile_02_07.png', 'd_tile_02_08.png',
  ];

  // 3. 특수패 (Special Tiles: 꽃, 계절 및 기타)
  static const List<String> specials = [
    'd_tile_03_02.png', 'd_tile_03_05.png', 'd_tile_03_10.png', 'd_tile_03_13.png',
    'd_tile_04_03.png', 'd_tile_04_04.png', 'd_tile_04_06.png', 'd_tile_04_07.png', 'd_tile_04_08.png',
    'd_tile_05_07.png', 'd_tile_06_03.png', 'd_tile_06_04.png', 'd_tile_08_05.png', 'd_tile_08_10.png',
    'd_tile_09_01.png', 'd_tile_09_03.png', 'd_tile_09_04.png', 'd_tile_10_06.png', 'd_tile_10_08.png',
    'e_tile_00_00.png', 'e_tile_00_01.png', 'e_tile_00_02.png', 'e_tile_00_03.png', 'e_tile_00_04.png', 'e_tile_00_05.png', 'e_tile_00_06.png', 'e_tile_00_07.png', 'e_tile_00_08.png', 'e_tile_00_09.png', 'e_tile_00_10.png', 'e_tile_00_11.png',
    'e_tile_01_05.png', 'e_tile_01_09.png', 'e_tile_01_10.png', 'e_tile_01_13.png',
    'e_tile_03_02.png', 'e_tile_03_04.png', 'e_tile_04_13.png', 'e_tile_07_04.png',
    'e_tile_08_01.png', 'e_tile_08_02.png', 'e_tile_08_03.png', 'e_tile_08_04.png', 'e_tile_08_10.png', 'e_tile_08_13.png',
    'e_tile_09_00.png', 'e_tile_09_02.png', 'e_tile_09_03.png', 'e_tile_09_04.png', 'e_tile_09_10.png', 'e_tile_09_11.png', 'e_tile_09_12.png', 'e_tile_09_13.png',
    'e_tile_10_02.png', 'e_tile_10_04.png', 'e_tile_10_10.png',
    'f_tile_00_00.png', 'f_tile_00_01.png', 'f_tile_00_02.png', 'f_tile_00_03.png', 'f_tile_00_04.png', 'f_tile_00_05.png', 'f_tile_00_06.png', 'f_tile_00_07.png', 'f_tile_00_08.png', 'f_tile_00_09.png', 'f_tile_00_10.png', 'f_tile_00_11.png', 'f_tile_00_12.png', 'f_tile_00_13.png',
    'f_tile_01_00.png', 'f_tile_01_01.png', 'f_tile_01_06.png', 'f_tile_01_07.png', 'f_tile_01_08.png', 'f_tile_01_09.png', 'f_tile_01_10.png', 'f_tile_01_13.png',
    'f_tile_02_06.png', 'f_tile_02_07.png', 'f_tile_02_08.png', 'f_tile_02_09.png', 'f_tile_02_10.png', 'f_tile_02_11.png', 'f_tile_02_12.png',
    'f_tile_03_07.png', 'f_tile_03_08.png', 'f_tile_04_00.png', 'f_tile_04_01.png', 'f_tile_04_06.png', 'f_tile_04_07.png', 'f_tile_04_10.png',
    'f_tile_05_07.png', 'f_tile_05_08.png', 'f_tile_05_10.png', 'f_tile_06_03.png', 'f_tile_07_07.png', 'f_tile_07_10.png',
    'f_tile_08_07.png', 'f_tile_08_08.png', 'f_tile_09_07.png', 'f_tile_10_06.png', 'f_tile_10_07.png', 'f_tile_10_08.png', 'f_tile_10_10.png',
  ];

  final int rows;
  final int cols;
  
  SichuanLogic({required this.rows, required this.cols});

  List<String> generateBoard() {
    int totalTiles = (rows - 2) * (cols - 2);
    if (totalTiles % 2 != 0) throw Exception("Board size must be even");

    List<String> deck = [];
    Random random = Random();

    // 비율 설정: 수패 70%, 자패 20%, 특수패 10% 기반 동적 계산
    int totalPairs = pairs;
    int numSpecials = totalPairs ~/ 10; // 10%
    int numHonors = totalPairs ~/ 5;    // 20%
    int numNumbers = totalPairs - numSpecials - numHonors; // 나머지 70%

    void addPairsFromList(List<String> list, int count) {
      if (count <= 0) return;
      List<String> shuffledList = List.from(list)..shuffle(random);
      for (int i = 0; i < count; i++) {
        String tile = shuffledList[i % shuffledList.length];
        deck.add(tile);
        deck.add(tile);
      }
    }

    addPairsFromList(numbers, numNumbers);
    addPairsFromList(honors, numHonors);
    addPairsFromList(specials, numSpecials);
    
    deck.shuffle(random);

    // 2D 보드 생성 (테두리는 빈 값)
    List<String> board = List.filled(rows * cols, '');
    
    int deckIndex = 0;
    for (int r = 1; r < rows - 1; r++) {
      for (int c = 1; c < cols - 1; c++) {
        board[r * cols + c] = deck[deckIndex++];
      }
    }
    
    return board;
  }

  // 두 좌표(1D index) 연결 가능 여부 및 경로(List<int>) 반환
  // 경로가 없으면 null 반환
  List<int>? getPath(List<String> board, int start, int end) {
    if (board[start] != board[end]) return null; // 모양이 다르면 불가
    if (board[start] == '' || board[end] == '') return null; // 빈 곳은 선택 불가

    // BFS 탐색
    // 상태: (index, direction, turns, path)
    // direction: 0:none, 1:up, 2:down, 3:left, 4:right
    
    Queue<_Node> queue = Queue();
    queue.add(_Node(start, -1, 0, [start]));
    
    // 방문 체크: [index][direction] -> minTurns
    // 같은 지점에 더 적은 꺾임으로 도달한 경우만 큐에 추가
    var visited = List.generate(rows * cols, (_) => List.filled(5, 999));

    // 상하좌우 오프셋
    final directions = [-cols, cols, -1, 1]; // Up, Down, Left, Right
    // Direction ID 매핑: 0:Up, 1:Down, 2:Left, 3:Right
    
    while (queue.isNotEmpty) {
      _Node current = queue.removeFirst();

      if (current.index == end) {
         return current.path;
      }

      int r = current.index ~/ cols;
      int c = current.index % cols;

      for (int i = 0; i < 4; i++) {
        int nextIndex = current.index + directions[i];
        int nr = nextIndex ~/ cols;
        int nc = nextIndex % cols;

        // 보드 범위 체크 (wrapping 방지)
        if (nextIndex < 0 || nextIndex >= rows * cols) continue;
        // 좌우 이동 시 행이 바뀌면 안됨, 상하 이동 시에는 자동으로 처리됨(nextIndex 범위 체크)
        // 하지만 -1(Left) 시 c=0에서 -1 되어 이전 행의 마지막으로 가는 것 방지해야 함.
        if (i == 2 && c == 0) continue; // Left 불가
        if (i == 3 && c == cols - 1) continue; // Right 불가

        // 회전 수 계산
        int nextTurns = current.turns;
        if (current.dir != -1 && current.dir != i) {
           nextTurns++;
        }

        if (nextTurns > 2) continue; // 2번 초과 꺾임 불가

        // 빈 칸이거나 목적지여야 함
        bool isEmpty = board[nextIndex] == '';
        bool isDest = nextIndex == end;

        if (isEmpty || isDest) {
            if (nextTurns < visited[nextIndex][i] || (nextTurns == visited[nextIndex][i])) { // 같은 꺾임수도 허용 (다른 경로일 수 있음)
                 // visited update
                 visited[nextIndex][i] = nextTurns;
                 
                 // path 복사 및 추가
                 List<int> newPath = List.from(current.path)..add(nextIndex);
                 queue.add(_Node(nextIndex, i, nextTurns, newPath));
            }
        }
      }
    }
    
    return null;
  }

  // 힌트 찾기 (가능한 쌍 하나 반환)
  List<int>? findHint(List<String> board) {
    // 모든 존재하는 타일 pair에 대해 getPath 시도 (비효율적일 수 있으나 size가 작음)
    // 최적화: 같은 모양끼리 그룹핑 후 시도
    Map<String, List<int>> positions = {};
    for (int i = 0; i < board.length; i++) {
      if (board[i].isNotEmpty) {
        positions.putIfAbsent(board[i], () => []).add(i);
      }
    }

    for (var entry in positions.entries) {
      List<int> idxs = entry.value;
      for (int i = 0; i < idxs.length; i++) {
        for (int j = i + 1; j < idxs.length; j++) {
            var path = getPath(board, idxs[i], idxs[j]);
            if (path != null) {
              return [idxs[i], idxs[j]];
            }
        }
      }
    }
    return null;
  }
  
  // 더 이상 깰 수 있는 패가 없는지 확인
  bool isDeadlock(List<String> board) {
    return findHint(board) == null && board.any((t) => t.isNotEmpty);
  }
}

class _Node {
  int index;
  int dir; // 0~3, -1:start
  int turns;
  List<int> path;

  _Node(this.index, this.dir, this.turns, this.path);
}
