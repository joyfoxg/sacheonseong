import 'dart:collection';
import 'dart:math';

class SichuanLogic {
  // 사천성 보드 크기 (10x14 등 짝수 권장)
  // 유니코드 마작 타일 리스트
  static const List<String> tiles = [
    '🀀', '🀁', '🀂', '🀃', // 동남서북
    '🀄', '🀅', '🀆', // 중발백
    '🀇', '🀈', '🀉', '🀊', '🀋', '🀌', '🀍', '🀎', '🀏', // 만수패 1~9
    '🀐', '🀑', '🀒', '🀓', '🀔', '🀕', '🀖', '🀗', '🀘', // 통수패 1~9
    '🀙', '🀚', '🀛', '🀜', '🀝', '🀞', '🀟', '🀠', '🀡', // 삭수패 1~9
  ];

  final int rows;
  final int cols;
  
  SichuanLogic({required this.rows, required this.cols});

  // 빈 보드는 ''(empty string)으로 표현
  // 테두리를 빈 공간으로 감싸서 경로 탐색을 쉽게 함 (padding)
  // 실제 게임 보드 크기: (rows-2) x (cols-2)
  
  List<String> generateBoard() {
    int totalTiles = (rows - 2) * (cols - 2);
    if (totalTiles % 2 != 0) throw Exception("Board size must be even");

    List<String> deck = [];
    int pairs = totalTiles ~/ 2;
    
    // 타일 랜덤 선택 및 쌍으로 추가
    Random random = Random();
    for (int i = 0; i < pairs; i++) {
        String tile = tiles[random.nextInt(tiles.length)];
        deck.add(tile);
        deck.add(tile);
    }
    
    deck.shuffle();

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
