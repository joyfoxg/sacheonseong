import 'dart:collection';
import 'dart:math';
import 'difficulty.dart';
import 'challenge_stage_config.dart'; // 챌린지 모드 패턴

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
    'ts_tile_00_01.png', 'ts_tile_00_02.png', 'ts_tile_00_03.png', 'ts_tile_00_04.png', 'ts_tile_00_05.png', 'ts_tile_00_06.png', 'ts_tile_01_00.png', 'ts_tile_01_01.png', 'ts_tile_01_06.png', 'ts_tile_02_06.png', 'ts_tile_04_00.png', 'ts_tile_04_01.png', 'ts_tile_04_06.png', 'ts_tile_06_03.png',
    // sw: 삼원패
    'sw_tile_00_10.png', 'sw_tile_00_11.png', 'sw_tile_02_12.png', 'sw_tile_04_13.png',
    // pu: 풍패
    'pu_tile_00_07.png', 'pu_tile_00_08.png', 'pu_tile_00_09.png', 'pu_tile_01_09.png', 'pu_tile_09_11.png',
    // fl: 꽃
    'fl_tile_02_01.png', 'fl_tile_02_02.png', 'fl_tile_02_03.png', 'fl_tile_02_04.png', 'fl_tile_02_05.png', 'fl_tile_02_06.png', 'fl_tile_02_07.png', 'fl_tile_02_08.png', 'fl_tile_02_11.png', 'fl_tile_03_02.png', 'fl_tile_03_05.png', 'fl_tile_03_07.png', 'fl_tile_03_10.png', 'fl_tile_07_07.png',
    // dm: 동물
    'dm_tile_00_00.png', 'dm_tile_00_01.png', 'dm_tile_00_02.png', 'dm_tile_00_03.png', 'dm_tile_00_04.png', 'dm_tile_00_05.png', 'dm_tile_00_06.png', 'dm_tile_00_07.png', 'dm_tile_00_08.png', 'dm_tile_00_09.png', 'dm_tile_01_05.png', 'dm_tile_01_06.png', 'dm_tile_01_08.png', 'dm_tile_01_10.png', 'dm_tile_08_05.png', 'dm_tile_08_10.png', 'dm_tile_09_01.png', 'dm_tile_09_04.png',
    // dh: 도형
    'd_tile_04_06.png', 'dh_d_tile_01_09.png', 'dh_d_tile_03_13.png', 'dh_d_tile_04_03.png', 'dh_d_tile_04_04.png', 'dh_d_tile_04_07.png', 'dh_d_tile_05_07.png', 'dh_d_tile_06_03.png', 'dh_d_tile_06_04.png', 'dh_d_tile_10_06.png', 'dh_d_tile_10_08.png', 'dh_dh_tile_00_06.png', 'dh_dh_tile_00_07.png', 'dh_tile_00_04.png', 'dh_tile_00_12.png', 'dh_tile_00_13.png', 'dh_tile_01_01.png', 'dh_tile_01_02.png', 'dh_tile_01_03.png', 'dh_tile_01_04.png', 'dh_tile_01_09.png', 'dh_tile_01_11.png', 'dh_tile_01_12.png', 'dh_tile_02_04.png', 'dh_tile_02_05.png', 'dh_tile_02_06.png', 'dh_tile_02_07.png', 'dh_tile_03_03.png', 'dh_tile_03_05.png', 'dh_tile_03_11.png', 'dh_tile_03_12.png', 'dh_tile_04_00.png', 'dh_tile_04_02.png', 'dh_tile_04_03.png', 'dh_tile_04_11.png', 'dh_tile_04_12.png', 'dh_tile_04_13.png', 'dh_tile_05_00.png', 'dh_tile_05_02.png', 'dh_tile_05_03.png', 'dh_tile_05_04.png', 'dh_tile_05_05.png', 'dh_tile_05_13.png', 'dh_tile_06_00.png', 'dh_tile_07_00.png', 'dh_tile_07_03.png', 'dh_tile_07_04.png', 'dh_tile_07_05.png', 'dh_tile_07_06.png', 'dh_tile_07_07.png', 'dh_tile_07_08.png', 'dh_tile_07_09.png', 'dh_tile_07_12.png', 'dh_tile_07_13.png', 'dh_tile_08_00.png', 'dh_tile_08_04.png', 'dh_tile_08_07.png', 'dh_tile_08_08.png', 'dh_tile_08_12.png', 'dh_tile_08_13.png', 'dh_tile_09_00.png', 'dh_tile_09_05.png', 'dh_tile_09_07.png', 'dh_tile_09_08.png', 'dh_tile_09_13.png', 'dh_tile_10_00.png', 'dh_tile_10_01.png', 'dh_tile_10_05.png', 'dh_tile_10_09.png', 'dh_tile_10_10.png', 'dh_tile_10_11.png',
    // sm: 사물
    'sm_tile_01_08.png', 'sm_tile_02_09.png', 'sm_tile_02_11.png', 'sm_tile_03_07.png', 'sm_tile_03_08.png', 'sm_tile_04_08.png', 'sm_tile_04_09.png', 'sm_tile_04_10.png', 'sm_tile_05_07.png', 'sm_tile_05_09.png', 'sm_tile_05_10.png', 'sm_tile_06_04.png', 'sm_tile_06_05.png', 'sm_tile_06_08.png', 'sm_tile_06_09.png', 'sm_tile_06_11.png', 'sm_tile_06_12.png',
    // pt: 패턴
    'pt_tile_00_00.png', 'pt_tile_00_01.png', 'pt_tile_00_03.png', 'pt_tile_01_00.png', 'pt_tile_01_10.png', 'pt_tile_02_03.png', 'pt_tile_04_01.png', 'pt_tile_06_01.png', 'pt_tile_06_02.png', 'pt_tile_06_03.png', 'pt_tile_07_01.png', 'pt_tile_07_02.png', 'pt_tile_08_01.png', 'pt_tile_08_02.png', 'pt_tile_08_13.png', 'pt_tile_09_01.png', 'pt_tile_09_02.png', 'pt_tile_09_04.png', 'pt_tile_09_06.png', 'pt_tile_09_09.png', 'pt_tile_09_12.png', 'pt_tile_09_13.png', 'pt_tile_10_02.png', 'pt_tile_10_03.png', 'pt_tile_10_04.png', 'pt_tile_10_06.png', 'pt_tile_10_08.png',
  ];
  // 사천성 보드 크기 (10x14 등 짝수 권장)
  final int rows;
  final int cols;
  final Difficulty difficulty;
  final int? tileCount; // 챌린지 모드용 타일 수 (선택적)
  final int obstacleCount; // 챌린지 모드용 장애물 수 (선택적, 기본 0)
  final LayoutPattern? pattern; // 챌린지 모드용 배치 패턴 (선택적)
  
  SichuanLogic({
    required this.rows,
    required this.cols,
    this.difficulty = Difficulty.normal,
    this.tileCount,
    this.obstacleCount = 0,
    this.pattern,
  });

  List<String> generateBoard() {
    // 챌린지 모드인 경우 tileCount 사용, 아니면 기본 보드 크기 사용
    int totalTiles = tileCount ?? ((rows - 2) * (cols - 2));
    if (totalTiles % 2 != 0) throw Exception("Tile count must be even");

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
    } else if (difficulty == Difficulty.challenge) {
      // 챌린지 모드는 타일 수에 맞게 동적 조정
      poolSize = min(totalTiles ~/ 4, pool.length); // 타일 수의 1/4 정도 종류 사용
    } else {
      poolSize = 70; // 고급 난이도 완화: 전체 대신 70종으로 제한 (기존: pool.length)
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
    // 주의: 항상 2개(한 쌍)씩 추가하므로 deck.length + 2 <= totalTiles 조건 사용
    while (deck.length + 2 <= totalTiles) {
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
    
    // 최종 검증: deck 길이가 totalTiles와 정확히 일치하고 짝수인지 확인
    if (deck.length != totalTiles) {
      print("WARNING: Generated ${deck.length} tiles but expected $totalTiles - regenerating");
      // 혹시 1개 부족하거나 초과하면 재생성
      return generateBoard();
    }
    
    deck.shuffle(random);

    // 2D 보드 생성 (테두리는 빈 값)
    List<String> board = List.filled(rows * cols, '');
    
    // 패턴 마스크 생성 (true인 곳에만 타일 배치 가능)
    List<bool> mask = _getPatternMask(pattern);
    
    // 마스크에서 유효한 인덱스들만 수집 (테두리 제외)
    List<int> validIndices = [];
    for (int r = 1; r < rows - 1; r++) {
      for (int c = 1; c < cols - 1; c++) {
        int index = r * cols + c;
        if (mask[index]) {
          validIndices.add(index);
        }
      }
    }
    
    // 유효한 위치가 타일 수보다 적으면 안됨
    if (validIndices.length < totalTiles + obstacleCount) {
        // 남은 공간 강제 확보 (빈 공간 아무데나 추가)
        for (int r = 1; r < rows - 1; r++) {
            for (int c = 1; c < cols - 1; c++) {
                int index = r * cols + c;
                if (!validIndices.contains(index)) {
                    validIndices.add(index);
                    if (validIndices.length >= totalTiles + obstacleCount) break;
                }
            }
            if (validIndices.length >= totalTiles + obstacleCount) break;
        }
    }
    
    // validIndices 정렬: 중앙 상단부터 시작하여 좌우 대칭성을 유지하며 채우기
    // 1. 위에서 아래로 (Row 오름차순)
    // 2. 중앙에서 좌우로 멀어지도록 (Column 중앙 거리 오름차순)
    int centerC = cols ~/ 2;
    
    validIndices.sort((a, b) {
        int r1 = a ~/ cols;
        int c1 = a % cols;
        int distC1 = (c1 - centerC).abs();
        
        int r2 = b ~/ cols;
        int c2 = b % cols;
        int distC2 = (c2 - centerC).abs();
        
        // 1순위: 행 (위 -> 아래)
        if (r1 != r2) return r1.compareTo(r2);
        
        // 2순위: 중앙에서의 가로 거리 (중앙 -> 외곽)
        if (distC1 != distC2) return distC1.compareTo(distC2);
        
        // 3순위: 왼쪽 먼저 (같은 거리일 때)
        return c1.compareTo(c2);
    });

    // 더 완벽한 대칭을 위해:
    // 선택된 인덱스 리스트를 다시 구성
    List<int> selectedIndices = [];
    List<int> tempIndices = List.from(validIndices); // 복사본
    
    // 중앙열(centerC)에 있는 인덱스들과 그 외(좌우 쌍) 분리
    List<int> centerColIndices = [];
    List<List<int>> pairedIndices = []; // [[left, right], ...]
    
    // 맵핑
    Map<int, int> posToIndex = {};
    for (int idx in tempIndices) posToIndex[idx] = idx;
    
    for (int r = 1; r < rows - 1; r++) {
        // 중앙열 처리
        int centerIdx = r * cols + centerC;
        if (posToIndex.containsKey(centerIdx)) {
            centerColIndices.add(centerIdx);
        }
        
        // 좌우 쌍 처리
        for (int c = 1; c < centerC; c++) {
            int leftIdx = r * cols + c;
            int rightIdx = r * cols + (cols - 1 - c); // 대칭점 (cols가 7이면 0..6, center=3. c=1 <-> 6-1=5)
            // cols는 전체 크기이므로 index는 0 ~ cols-1.
            // 대칭 공식: (cols-1) - c. 
            // 예: cols=7. indices 0,1,2,3,4,5,6. center=3. 
            // c=1 <-> 7-1-1=5. c=2 <-> 7-1-2=4.
            
            if (posToIndex.containsKey(leftIdx) && posToIndex.containsKey(rightIdx)) {
                pairedIndices.add([leftIdx, rightIdx]);
            }
        }
    }
    
    // 장애물 위치 확보 전략 수정:
    // "블록들 사이"에 위치해야 하므로, 가장자리가 아닌 내부 위치를 우선적으로 선택해야 함.
    // 기존 로직은 남은 쌍이나 중앙열을 사용했는데, 이는 외곽일 수도 있음.
    
    // 1. 내부 인덱스(Inner Indices) 식별
    // (테두리보다 한 칸 더 안쪽: r 2~rows-3, c 2~cols-3)
    List<int> innerIndices = [];
    for (int idx in tileIndices) { // 이미 타일이 배치될 예정인 위치들 중에서 선별
        int r = idx ~/ cols;
        int c = idx % cols;
        if (r >= 2 && r < rows - 2 && c >= 2 && c < cols - 2) {
            innerIndices.add(idx);
        }
    }
    
    // 2. 장애물을 배치할 위치를 innerIndices에서 무작위 선택하여 교체
    // (즉, 타일이 놓일 자리를 뺏어서 장애물을 놓고, 뺏긴 타일은 다른 빈자리나 외곽으로 이동)
    // 하지만 타일 쌍이 깨지면 안되므로, 타일 쌍의 위치를 통째로 옮기거나 해야 함 -> 복잡.
    
    // 더 단순한 접근:
    // 아예 처음부터 obstacleCount만큼을 "내부 위치"에서 먼저 확보하고 시작.
    
    // 재작성된 로직:
    
    // 재작성된 로직:
    
    // 다시 초기화 (선언 포함)
    List<int> tileIndices = [];
    List<int> obstacleIndices = [];
    
    // 1. 장애물 위치 확보 (내부 중심)
    List<int> collectedInner = [];
    List<int> collectedOuter = [];
    
    // pairedIndices를 내부/외부로 분류
    List<List<int>> innerPairs = [];
    List<List<int>> outerPairs = [];
    
    for (var pair in pairedIndices) {
        int r1 = pair[0] ~/ cols;
        int c1 = pair[0] % cols;
        // pair[0]만 봐도 대칭이므로 r은 같고 c는 반대. 하나가 내부면 다른 하나도 내부일 확률 높음(대칭구조상)
        // 엄밀히는 둘 다 체크
        bool isInner1 = (r1 >= 2 && r1 < rows - 2 && c1 >= 2 && c1 < cols - 2);
        
        if (isInner1) innerPairs.add(pair);
        else outerPairs.add(pair);
    }
    
    // centerColIndices도 분류
    List<int> innerCenter = [];
    List<int> outerCenter = [];
    for (int idx in centerColIndices) {
        int r = idx ~/ cols;
        int c = idx % cols;
        if (r >= 2 && r < rows - 2 && c >= 2 && c < cols - 2) innerCenter.add(idx);
        else outerCenter.add(idx);
    }
    
    // 장애물 배치 (Inner 우선)
    int currentObstacles = 0;
    
    // (1) Inner Center에서 하나씩 뽑기 (홀수 장애물 처리 용이, 중앙 알박기)
    innerCenter.shuffle(random);
    while (currentObstacles < obstaclesNeeded && innerCenter.isNotEmpty) {
        obstacleIndices.add(innerCenter.removeAt(0));
        currentObstacles++;
    }
    
    // (2) Inner Pairs에서 뽑기 (쌍을 깨서 장애물 2개로 쓰거나, 1개 쓰고 1개 버리기?)
    // 장애물은 쌍일 필요 없음. 그냥 위치만 잡으면 됨.
    // Inner Pair를 깨서 두 자리를 모두 장애물로 쓰면 대칭성 유지됨.
    innerPairs.shuffle(random);
    while (currentObstacles < obstaclesNeeded && innerPairs.isNotEmpty) {
        // 2개 다 장애물로
        var pair = innerPairs.removeAt(0);
        obstacleIndices.add(pair[0]);
        currentObstacles++;
        if (currentObstacles < obstaclesNeeded) {
            obstacleIndices.add(pair[1]);
            currentObstacles++;
        } else {
            // 하나 남은 건 타일용 풀(tempIndices 등)로 돌려야 함
            // 복잡하니 일단 outerCenter나 나중에 처리
            // 여기서는 그냥 버려짐(타일 배치 때 다시 수집됨) -> 아니면 explicit하게 남은걸 tileCandidates에 넣어야 함.
            // 로직 단순화를 위해 일단 넘어감 (pairsNeeded 계산시 다시 수집 로직 필요)
            // -> 위쪽 로직 구조상, unused positions는 사용 안됨.
            // -> 해결책: 사용 안 된 index는 나중에 tileIndices 채울 때 활용해야 함.
            // 하지만 지금 구조는 "pairedIndices"에서 꺼내 쓰는 방식.
            // 남은 하나는 outerCenter(사실상 single pool)에 넣는게 맞음.
            outerCenter.add(pair[1]); 
        }
    }
    
    // (3) 아직도 부족하면 Outer Inner (없음) -> Outer Center
    while (currentObstacles < obstaclesNeeded && outerCenter.isNotEmpty) {
        obstacleIndices.add(outerCenter.removeAt(0));
        currentObstacles++;
    }
    
    // (4) Outer Pairs
    while (currentObstacles < obstaclesNeeded && outerPairs.isNotEmpty) {
        var pair = outerPairs.removeAt(0);
        obstacleIndices.add(pair[0]);
        currentObstacles++;
         if (currentObstacles < obstaclesNeeded) {
            obstacleIndices.add(pair[1]);
            currentObstacles++;
        } else {
             outerCenter.add(pair[1]);
        }
    }
    
    // 타일 배치 (남은 Pair들 + Center들)
    // 남은 Inner Pairs, Outer Pairs 합치기
    List<List<int>> allTilePairs = [...innerPairs, ...outerPairs];
    // 남은 Center들 (Inner Center는 다 썼을 듯, Outer Center는 남았을 수도)
    List<int> allTileSingles = [...innerCenter, ...outerCenter];
    
    // 타일은 쌍(Pair) 단위로 배치되어야 함 (board matching을 위해)
    // deck에는 이미 쌍으로 들어있음.
    // 위치(tileIndices)도 쌍으로 제공하는 게 이상적이지만, 셔플될거라 상관은 없음.
    // 단, "위치 갯수"는 정확히 totalTiles여야 함.
    
    // Pair 위치들 먼저 확보
    if (allTilePairs.length >= pairsNeeded) {
        for (int i = 0; i < pairsNeeded; i++) {
            tileIndices.addAll(allTilePairs[i]);
        }
    } else {
        // Pair 다 쓰고
        for (var pair in allTilePairs) {
            tileIndices.addAll(pair);
        }
        
        // 부족분은 Singles에서 채움
        int remaining = totalTiles - tileIndices.length;
        for (int i = 0; i < remaining && i < allTileSingles.length; i++) {
            tileIndices.add(allTileSingles[i]);
        }
        
        // 그래도 부족하면 tempIndices (미사용분) 뒤짐
        for (int idx in tempIndices) {
            if (tileIndices.length >= totalTiles) break;
            if (!tileIndices.contains(idx) && !obstacleIndices.contains(idx)) {
                tileIndices.add(idx);
            }
        }
    }

    // 최종 배치
    // 1. 타일
    for (int i = 0; i < deck.length && i < tileIndices.length; i++) {
        board[tileIndices[i]] = deck[i];
    }
    
    // 2. 장애물
    for (int idx in obstacleIndices) {
        board[idx] = 'BLOCK';
    }
    
    return board;
  }

  // 패턴에 따른 마스크 생성
  List<bool> _getPatternMask(LayoutPattern? pattern) {
    List<bool> mask = List.filled(rows * cols, false);
    int centerR = rows ~/ 2;
    int centerC = cols ~/ 2;

    for (int r = 1; r < rows - 1; r++) {
      for (int c = 1; c < cols - 1; c++) {
        bool isValid = true;
        
        if (pattern == null || pattern == LayoutPattern.pyramid) {
             // 기본 직사각형 (모두 true)
             isValid = true;
        } else if (pattern == LayoutPattern.diamond) {
            // 마름모: |r-center| + |c-center| <= limit
            if ((r - centerR).abs() + (c - centerC).abs() > (min(rows, cols) ~/ 2) - 1) {
                isValid = false;
            }
        } else if (pattern == LayoutPattern.cross) {
            // 십자가: r이 범위 내 or c가 범위 내
            if ((r - centerR).abs() > 1 && (c - centerC).abs() > 1) {
                isValid = false;
            }
        } else if (pattern == LayoutPattern.ring) {
            // 링: 중심에서 일정 거리 이상, 일정 거리 이하
            int dist = (r - centerR).abs() + (c - centerC).abs();
            if (dist < 2 || dist > 5) isValid = false;
        } else if (pattern == LayoutPattern.border) { 
             // 테두리형: 가장자리만 사용
             if (r > 2 && r < rows - 3 && c > 2 && c < cols - 3) isValid = false;
        } else if (pattern == LayoutPattern.stripes) {
            // 줄무늬: 짝수 행만 or 홀수 행만
            if (r % 2 != 0) isValid = false;
        } else if (pattern == LayoutPattern.zigzag) {
            // 지그재그 (체스판)
            if ((r + c) % 2 != 0) isValid = false;
        } else if (pattern == LayoutPattern.hourglass) {
            // 모래시계
            if ((r - centerR).abs() < (c - centerC).abs()) isValid = false;
        }
        // stairs, spiral, cluster 등은 기본적으로 전체 허용하되 배치 순서로 모양 결정
        
        mask[r * cols + c] = isValid;
      }
    }
    return mask;
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

  // 남은 타일들을 재배치 (셔플)
  // 매칭 가능한 쌍이 나오도록 보장
  List<String> shuffleBoard(List<String> currentBoard) {
    // 1. 현재 남은 타일 수집
    List<String> remainingTiles = [];
    List<int> collectedIndices = [];
    
    for (int i = 0; i < currentBoard.length; i++) {
        if (currentBoard[i].isNotEmpty) {
            remainingTiles.add(currentBoard[i]);
            collectedIndices.add(i);
        }
    }
    
    if (remainingTiles.isEmpty) return currentBoard;

    Random random = Random();
    List<String> newBoard = List.from(currentBoard);
    int retryCount = 0;

    do {
        // 2. 타일 섞기
        remainingTiles.shuffle(random);
        
        // 3. 원래 있던 위치들에 다시 배치
        for (int i = 0; i < collectedIndices.length; i++) {
            newBoard[collectedIndices[i]] = remainingTiles[i];
        }
        
        retryCount++;
        // 100번 시도해도 안되면 그냥 반환 (무한 루프 방지)
    } while (isDeadlock(newBoard) && retryCount < 100);

    return newBoard;
  }
}

class _Node {
  int index;
  int dir; // 0~3, -1:start
  int turns;
  List<int> path;

  _Node(this.index, this.dir, this.turns, this.path);
}
