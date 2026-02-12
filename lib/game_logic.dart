import 'dart:collection';
import 'dart:math';
import 'difficulty.dart';

class SichuanLogic {
  // 사천성 보드 크기 (10x14 등 짝수 권장)
  // 유니코드 마작 타일 리스트
  // 11가지 카테고리 접두사 정의
  static const List<String> allTileFiles = [
    // ms: 만수패
    'ms_tile_00_00.png', 'ms_tile_00_01.png', 'ms_tile_00_02.png', 'ms_tile_00_03.png', 'ms_tile_00_04.png', 'ms_tile_00_05.png', 'ms_tile_00_06.png', 'ms_tile_01_05.png', 'ms_tile_03_02.png', 'ms_tile_03_04.png',
    // hm: 한자패
    'hm_tile_01_10.png', 'hm_tile_01_13.png', 'hm_tile_02_10.png', 'hm_tile_07_04.png', 'hm_tile_07_10.png', 'hm_tile_08_01.png', 'hm_tile_08_02.png', 'hm_tile_08_03.png', 'hm_tile_08_04.png', 'hm_tile_09_00.png', 'hm_tile_09_02.png', 'hm_tile_09_03.png', 'hm_tile_09_04.png', 'hm_tile_09_10.png', 'hm_tile_09_12.png', 'hm_tile_10_02.png', 'hm_tile_10_10.png',
    // ss: 삭수패
    'ss_tile_00_07.png', 'ss_tile_00_09.png', 'ss_tile_00_11.png', 'ss_tile_01_07.png', 'ss_tile_01_08.png', 'ss_tile_01_09.png', 'ss_tile_01_13.png', 'ss_tile_02_07.png', 'ss_tile_02_08.png', 'ss_tile_03_08.png', 'ss_tile_04_07.png', 'ss_tile_05_07.png', 'ss_tile_05_08.png', 'ss_tile_08_07.png', 'ss_tile_08_08.png', 'ss_tile_09_07.png', 'ss_tile_10_06.png', 'ss_tile_10_07.png', 'ss_tile_10_08.png',
    // ts: 통수패
    'ts_tile_00_00.png', 'ts_tile_00_01.png', 'ts_tile_00_02.png', 'ts_tile_00_03.png', 'ts_tile_00_04.png', 'ts_tile_00_05.png', 'ts_tile_00_06.png', 'ts_tile_01_00.png', 'ts_tile_01_01.png', 'ts_tile_01_06.png', 'ts_tile_02_06.png', 'ts_tile_04_00.png', 'ts_tile_04_01.png', 'ts_tile_04_06.png', 'ts_tile_06_03.png',
    // sw: 삼원패
    'sw_tile_00_10.png', 'sw_tile_00_11.png', 'sw_tile_02_12.png', 'sw_tile_04_13.png',
    // pu: 풍패
    'pu_tile_00_07.png', 'pu_tile_00_08.png', 'pu_tile_00_09.png', 'pu_tile_01_09.png', 'pu_tile_09_11.png',
    // fl: 꽃
    'fl_tile_02_01.png', 'fl_tile_02_02.png', 'fl_tile_02_03.png', 'fl_tile_02_04.png', 'fl_tile_02_05.png', 'fl_tile_02_06.png', 'fl_tile_02_07.png', 'fl_tile_02_08.png', 'fl_tile_02_11.png', 'fl_tile_03_02.png', 'fl_tile_03_05.png', 'fl_tile_03_07.png', 'fl_tile_03_10.png', 'fl_tile_07_07.png',
    // dm: 동물
    'dm_tile_00_00.png', 'dm_tile_00_01.png', 'dm_tile_00_02.png', 'dm_tile_00_03.png', 'dm_tile_00_04.png', 'dm_tile_00_05.png', 'dm_tile_00_06.png', 'dm_tile_00_07.png', 'dm_tile_00_08.png', 'dm_tile_00_09.png', 'dm_tile_01_05.png', 'dm_tile_01_06.png', 'dm_tile_01_08.png', 'dm_tile_01_10.png', 'dm_tile_08_05.png', 'dm_tile_08_10.png', 'dm_tile_09_01.png', 'dm_tile_09_04.png',
    // dh: 도형
    'dh_d_tile_01_09.png', 'dh_d_tile_03_13.png', 'dh_d_tile_04_03.png', 'dh_d_tile_04_04.png', 'dh_d_tile_05_07.png', 'dh_d_tile_06_03.png', 'dh_d_tile_06_04.png', 'dh_d_tile_10_06.png', 'dh_d_tile_10_08.png', 'dh_dh_tile_00_06.png', 'dh_dh_tile_00_07.png', 'dh_tile_00_04.png', 'dh_tile_00_12.png', 'dh_tile_00_13.png', 'dh_tile_01_01.png', 'dh_tile_01_02.png', 'dh_tile_01_03.png', 'dh_tile_01_04.png', 'dh_tile_01_09.png', 'dh_tile_01_11.png', 'dh_tile_01_12.png', 'dh_tile_02_04.png', 'dh_tile_02_05.png', 'dh_tile_02_06.png', 'dh_tile_02_07.png', 'dh_tile_03_03.png', 'dh_tile_03_05.png', 'dh_tile_03_11.png', 'dh_tile_03_12.png', 'dh_tile_04_00.png', 'dh_tile_04_02.png', 'dh_tile_04_03.png', 'dh_tile_04_11.png', 'dh_tile_04_12.png', 'dh_tile_04_13.png', 'dh_tile_05_00.png', 'dh_tile_05_02.png', 'dh_tile_05_03.png', 'dh_tile_05_04.png', 'dh_tile_05_05.png', 'dh_tile_05_13.png', 'dh_tile_06_00.png', 'dh_tile_07_00.png', 'dh_tile_07_03.png', 'dh_tile_07_04.png', 'dh_tile_07_05.png', 'dh_tile_07_06.png', 'dh_tile_07_07.png', 'dh_tile_07_08.png', 'dh_tile_07_09.png', 'dh_tile_07_12.png', 'dh_tile_07_13.png', 'dh_tile_08_00.png', 'dh_tile_08_04.png', 'dh_tile_08_07.png', 'dh_tile_08_08.png', 'dh_tile_08_12.png', 'dh_tile_08_13.png', 'dh_tile_09_00.png', 'dh_tile_09_05.png', 'dh_tile_09_07.png', 'dh_tile_09_08.png', 'dh_tile_09_13.png', 'dh_tile_10_00.png', 'dh_tile_10_01.png', 'dh_tile_10_05.png', 'dh_tile_10_09.png', 'dh_tile_10_10.png', 'dh_tile_10_11.png',
    // sm: 사물
    'sm_tile_01_08.png', 'sm_tile_02_09.png', 'sm_tile_02_11.png', 'sm_tile_03_07.png', 'sm_tile_03_08.png', 'sm_tile_04_08.png', 'sm_tile_04_09.png', 'sm_tile_04_10.png', 'sm_tile_05_07.png', 'sm_tile_05_09.png', 'sm_tile_05_10.png', 'sm_tile_06_04.png', 'sm_tile_06_05.png', 'sm_tile_06_08.png', 'sm_tile_06_09.png', 'sm_tile_06_11.png', 'sm_tile_06_12.png',
    // pt: 패턴
    'pt_tile_00_00.png', 'pt_tile_00_01.png', 'pt_tile_00_03.png', 'pt_tile_01_00.png', 'pt_tile_01_10.png', 'pt_tile_02_03.png', 'pt_tile_04_01.png', 'pt_tile_06_01.png', 'pt_tile_06_02.png', 'pt_tile_06_03.png', 'pt_tile_07_01.png', 'pt_tile_07_02.png', 'pt_tile_08_01.png', 'pt_tile_08_02.png', 'pt_tile_08_13.png', 'pt_tile_09_01.png', 'pt_tile_09_02.png', 'pt_tile_09_04.png', 'pt_tile_09_06.png', 'pt_tile_09_09.png', 'pt_tile_09_12.png', 'pt_tile_09_13.png', 'pt_tile_10_02.png', 'pt_tile_10_03.png', 'pt_tile_10_04.png', 'pt_tile_10_06.png', 'pt_tile_10_08.png',
  ];
  // 사천성 보드 크기 (10x14 등 짝수 권장)
  final int rows;
  final int cols;
  final Difficulty difficulty;
  
  SichuanLogic({required this.rows, required this.cols, this.difficulty = Difficulty.normal});

  List<String> generateBoard() {
    int totalTiles = (rows - 2) * (cols - 2);
    if (totalTiles % 2 != 0) throw Exception("Board size must be even");

    List<String> deck = [];
    Random random = Random();

    // 난이도에 따른 타일 풀 조정 (Easy일수록 종류를 줄여서 중복 확률 높임)
    List<String> pool = List.from(allTileFiles);
    pool.shuffle(random);
    
    int poolSize;
    if (difficulty == Difficulty.easy) {
      poolSize = 25; // 종류를 25개로 제한 -> 55쌍 / 25종 = 평균 2.2쌍 (4.4개) 중복
    } else if (difficulty == Difficulty.normal) {
      poolSize = 45; // 종류를 45개로 제한 -> 55쌍 / 45종 = 평균 1.2쌍
    } else {
      poolSize = pool.length; // 전체 사용
    }
    
    // 풀 크기만큼 자르기 (단, 최소한의 갯수는 보장되어야 함)
    poolSize = min(poolSize, pool.length);
    List<String> activeTiles = pool.sublist(0, poolSize);

    // 카테고리별 초기 분류 (선별된 activeTiles 기준)
    Map<String, List<String>> categories = {};
    for (String file in activeTiles) {
      String prefix = file.substring(0, 2);
      categories.putIfAbsent(prefix, () => []).add(file);
    }

    // 비중 설정 (전체 쌍수 기반)
    int totalPairs = totalTiles ~/ 2;
    
    // 필수 패 (수패 + 핵심 자패) 비중 극대화 (약 90%)
    int numMs = (totalPairs * 0.25).toInt(); // 만수 25%
    int numSs = (totalPairs * 0.25).toInt(); // 삭수 25%
    int numTs = (totalPairs * 0.25).toInt(); // 통수 25%
    int numHm = (totalPairs * 0.10).toInt(); // 한자 10%
    int numSpecialPures = (totalPairs * 0.08).toInt(); // 삼원패/풍패 8%
    int numOthers = totalPairs - numMs - numSs - numTs - numHm - numSpecialPures; // 나머지 장식 7%
    
    void addPairs(String prefix, int count) {
      List<String>? list = categories[prefix];
      if (list == null || list.isEmpty || count <= 0) return;
      List<String> shuffled = List.from(list)..shuffle(random);
      for (int i = 0; i < count; i++) {
        String tile = shuffled[i % shuffled.length];
        deck.add(tile);
        deck.add(tile);
      }
    }

    addPairs('ms', numMs);
    addPairs('ss', numSs);
    addPairs('ts', numTs);
    addPairs('hm', numHm);
    
    // sw, pu 합쳐서 처리
    List<String> specialPuresList = [...(categories['sw'] ?? []), ...(categories['pu'] ?? [])];
    if (specialPuresList.isNotEmpty) {
      specialPuresList.shuffle(random);
      for (int i = 0; i < numSpecialPures; i++) {
        String tile = specialPuresList[i % specialPuresList.length];
        deck.add(tile);
        deck.add(tile);
      }
    }

    // 나머지 장식 패들 (fl, dm, dh, sm, pt) 섞어서 처리
    List<String> othersList = [
      ...(categories['fl'] ?? []), ...(categories['dm'] ?? []),
      ...(categories['dh'] ?? []), ...(categories['sm'] ?? []),
      ...(categories['pt'] ?? [])
    ];
    if (othersList.isNotEmpty && numOthers > 0) {
      othersList.shuffle(random);
      for (int i = 0; i < numOthers; i++) {
        String tile = othersList[i % othersList.length];
        deck.add(tile);
        deck.add(tile);
      }
    }

    // 혹시라도 totalPairs가 차지 않았다면 부족한 만큼 현재 풀에서 랜덤 보충
    // 남은 공간을 짝패로 정확히 채움
    while (deck.length < totalTiles) {
      // 공간이 2개 미만으로 남았는데 루프가 돌면 안됨 (totalTiles는 짝수이므로 이론상 발생 안 함)
      // 하지만 안전을 위해 체크
      if (totalTiles - deck.length < 2) break;

      String tile;
      if (activeTiles.isNotEmpty) {
        tile = activeTiles[random.nextInt(activeTiles.length)];
      } else {
        // 비상용
        tile = allTileFiles[random.nextInt(allTileFiles.length)];
      }
      
      deck.add(tile);
      deck.add(tile);
    }
    
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
