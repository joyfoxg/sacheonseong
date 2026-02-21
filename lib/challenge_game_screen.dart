import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart';
import 'audio_manager.dart';
import 'challenge_stage_config.dart';
import 'leaderboard_service.dart';
import 'widgets/particle_overlay.dart';
import 'widgets/neon_path_painter.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class ChallengeGameScreen extends StatefulWidget {
  final int stage;

  const ChallengeGameScreen({super.key, required this.stage});

  @override
  State<ChallengeGameScreen> createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  late SichuanLogic _logic;
  late StageConfig _config;

  // Board dimensions (dynamic)
  int _rows = 14; 
  int _cols = 5;  // 가로 5열 요청

  List<String> _board = [];
  int _selectedIndex = -1;
  List<int>? _selectedPath;

  // 점수 시스템
  int _score = 0;
  int _pairsCleared = 0;

  // 타이머
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _remainingSeconds = 0;

  // 상태
  String _state = 'preparing'; // preparing, playing, finished

  // 아이템
  int _shuffleCount = 1;
  int _hintCount = 2;

  Timer? _pathClearTimer;
  
  // 파티클 시스템
  final ParticleSystem _particleSystem = ParticleSystem();
  late final Ticker _ticker;
  double _tileWidth = 0;
  double _tileHeight = 0;

  @override
  void initState() {
    super.initState();
    _config = ChallengeStages.getStage(widget.stage);
    
    // 타일 수에 따라 그리드 크기 최적화 (타일 크기 최대화)
    // SichuanLogic은 테두리 1칸씩을 제외하고 배치하므로, 원하는 열 수 + 2를 해야 함
    if (_config.tileCount <= 40) {
      _cols = 7;  // 실제 타일 5열 (7-2)
      _rows = 14; 
    } else if (_config.tileCount <= 60) {
      _cols = 8;  // 실제 타일 6열 (8-2)
      _rows = 14;
    } else if (_config.tileCount <= 80) {
      _cols = 10; // 실제 타일 8열 (10-2)
      _rows = 14;
    } else {
      _cols = 12; // 실제 타일 10열 (12-2)
      _rows = 14;
    }

    // 패턴 마스크를 고려하여 유효 공간 구하기 및 격자 크기 자동 확장
    int requiredTiles = _config.tileCount + _config.obstacleCount;
    int validSpaces = _calculateValidSpaces(_rows, _cols, _config.pattern);
    
    while (validSpaces < requiredTiles) {
      _cols += 2; // 가로 대칭을 위해 2칸씩 늘림
      if (_cols > _rows) {
          _rows += 2;
      }
      validSpaces = _calculateValidSpaces(_rows, _cols, _config.pattern);
      
      // 무한루프 방지
      if (_cols > 20 || _rows > 30) {
          debugPrint("Warning: Max grid size reached.");
          break;
      }
    }

    _logic = SichuanLogic(
      rows: _rows,
      cols: _cols,
      tileCount: _config.tileCount,
      obstacleCount: _config.obstacleCount, // 장애물 수 전달
      pattern: _config.pattern,
    );
    _remainingSeconds = _config.timeLimitSeconds;
    
    // 파티클 업데이트 루프 시작
    _ticker = createTicker((elapsed) {
      _particleSystem.update();
    });
    _ticker.start();
    
    _startGame();
  }

  void _startGame() {
    _board = _logic.generateBoard();
    // 풀 수 없는 판이면 다시 섮기 시도
    int retry = 0;
    while (_logic.isDeadlock(_board) && retry < 10) {
      _board = _logic.generateBoard();
      retry++;
    }
    _state = 'playing';
    _stopwatch.start();
    
    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        _remainingSeconds--;
        
        // 시간 초과
        if (_remainingSeconds <= 0) {
          _gameOver(false);
        }
      });
    });
  }

  int _calculateValidSpaces(int rows, int cols, LayoutPattern? pattern) {
    int count = 0;
    int centerR = rows ~/ 2;
    int centerC = cols ~/ 2;

    for (int r = 1; r < rows - 1; r++) {
      for (int c = 1; c < cols - 1; c++) {
        bool isValid = true;
        
        if (pattern == null || pattern == LayoutPattern.pyramid) {
             isValid = true;
        } else if (pattern == LayoutPattern.diamond) {
            if ((r - centerR).abs() + (c - centerC).abs() > (math.min(rows, cols) ~/ 2) - 1) isValid = false;
        } else if (pattern == LayoutPattern.cross) {
            if ((r - centerR).abs() > 1 && (c - centerC).abs() > 1) isValid = false;
        } else if (pattern == LayoutPattern.ring) {
            int dist = (r - centerR).abs() + (c - centerC).abs();
            int maxDist = (math.min(rows, cols) ~/ 2) - 1;
            int innerDist = math.max(2, maxDist ~/ 2);
            if (dist < innerDist || dist > maxDist) isValid = false;
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

  Widget _buildTile(int index) {
    final tile = _board[index];
    if (tile.isEmpty) return const SizedBox.shrink();

    // 장애물 처리
    if (tile == 'BLOCK') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.lock, color: Colors.grey, size: 24),
        ),
      );
    }

    final isSelected = index == _selectedIndex;
    final isInPath = _selectedPath?.contains(index) ?? false;

    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withOpacity(0.5)
              : isInPath
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Image.asset(
          'assets/image/tiles/$tile',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                tile,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
    
  void _onShuffle() {
    if (_state != 'playing' || _shuffleCount <= 0) return;
    
    setState(() {
      _board = _logic.shuffleBoard(_board);
      _shuffleCount--;
      _selectedIndex = -1;
      _selectedPath = null;
    });
    
    _audioManager.playSelect(); // 효과음 (임시)
  }

  void _onHint() {
    if (_state != 'playing' || _hintCount <= 0) return;

    List<int>? hint = _logic.findHint(_board);
    if (hint != null && hint.isNotEmpty) {
      setState(() {
        _hintCount--;
        // 힌트 타일들을 잠시 강조 (선택된 것처럼 표시)
        _selectedIndex = hint[0];
        // 혹은 별도의 하이라이트 처리를 할 수도 있음
      });
      _audioManager.playSelect(); // 효과음 (임시)
    } else {
      // 힌트가 없음 (재섞기 필요 상황이지만 여기선 패스)
    }
  }

  void _onTileTap(int index) {
    if (_state != 'playing') return;
    if (_board[index] == '') return; // 빈 칸

    _audioManager.playSelect();

    if (_selectedIndex == -1) {
      // 첫 번째 타일 선택
      setState(() {
        _selectedIndex = index;
        _selectedPath = null;
      });
    } else if (_selectedIndex == index) {
      // 같은 타일 다시 클릭 - 선택 해제
      setState(() {
        _selectedIndex = -1;
        _selectedPath = null;
      });
    } else {
      // 두 번째 타일 선택
      final path = _logic.getPath(_board, _selectedIndex, index);
      if (path != null) {
        // 매칭 성공
        setState(() {
          _selectedPath = path;
        });

        _audioManager.playSuccess();
        
        // 파티클 효과 생성
        if (_tileWidth > 0 && _tileHeight > 0) {
          int r1 = _selectedIndex ~/ _cols;
          int c1 = _selectedIndex % _cols;
          int r2 = index ~/ _cols;
          int c2 = index % _cols;
          
          // 패딩 10, spacing 2 고려
          double x1 = 10.0 + c1 * (_tileWidth + 2) + _tileWidth / 2;
          double y1 = 10.0 + r1 * (_tileHeight + 2) + _tileHeight / 2;
          double x2 = 10.0 + c2 * (_tileWidth + 2) + _tileWidth / 2;
          double y2 = 10.0 + r2 * (_tileHeight + 2) + _tileHeight / 2;
          
          _particleSystem.addExplosion(Offset(x1, y1));
          _particleSystem.addExplosion(Offset(x2, y2));
        }

        // 점수 추가
        _pairsCleared++;
        _score += 100;

        // 타일 제거
        _board[_selectedIndex] = '';
        _board[index] = '';

        // 타일 제거 후 경로 초기화
        _pathClearTimer?.cancel();
        _pathClearTimer = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            _selectedPath = null;
            _selectedIndex = -1;

            // 클리어 체크
            // BLOCK은 남아있어도 클리어로 간주해야 함
            bool isAllCleared = _board.every((tile) => tile.isEmpty || tile == 'BLOCK');
            
            if (isAllCleared) {
              _gameOver(true);
            } else {
              // 남은 타일이 2개인데 짝이 안 맞는 경우 자동 클리어 (버그 방지)
              int remainingCount = 0;
              List<int> remainingIndices = [];
              for(int i=0; i<_board.length; i++) {
                 if (_board[i].isNotEmpty && _board[i] != 'BLOCK') {
                    remainingCount++;
                    remainingIndices.add(i);
                 }
              }
              
              if (remainingCount == 2) {
                 final tile1 = _board[remainingIndices[0]];
                 final tile2 = _board[remainingIndices[1]];
                 
                 if (tile1 != tile2) {
                    // 짝이 안 맞으면 강제 클리어 처리
                    // (사용자가 갇히지 않게)
                    _board[remainingIndices[0]] = '';
                    _board[remainingIndices[1]] = '';
                    _gameOver(true);
                 }
              } else {
                 // 3개 이상 남았을 때 Deadlock 체크
                 if (_logic.isDeadlock(_board)) {
                    // 타이머 안에서 실행되므로 mounted 체크 필요
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("패가 꼬여서 자동으로 섞습니다!")));
                    }
                    _autoShuffle();
                 }
              }
            }
          });
        });
      } else {
        // 매칭 실패
        _audioManager.playFail();
        setState(() {
          _selectedIndex = -1;
          _selectedPath = null;
        });
      }
    }
  }

  void _gameOver(bool cleared) {
    _timer?.cancel();
    _stopwatch.stop();
    _state = 'finished';

    if (cleared) {
      // 시간 보너스 추가
      final timeBonus = _remainingSeconds * 100;
      _score += timeBonus;

      // 최고 점수 갱신 및 해금
      _saveScore(true);

      // 클리어 다이얼로그
      _showClearDialog(timeBonus);
    } else {
      // 실패 시에도 지금까지 모은 점수로 기기 최고점수 갱신
      _saveScore(false);
      // 실패 다이얼로그
      _showFailDialog();
    }
  }

  Future<void> _saveScore(bool cleared) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('challenge_stage_${widget.stage}_score') ?? 0;
    
    // 실패해도 점수는 지금까지 모은 점수로 로컬 최고 점수 갱신 가능
    if (_score > currentBest) {
      await prefs.setInt('challenge_stage_${widget.stage}_score', _score);
    }

    // 다음 단계 해금은 클리어 시에만
    if (cleared && widget.stage < 20) {
      final unlockedStage = prefs.getInt('challenge_unlocked_stage') ?? 1;
      if (widget.stage >= unlockedStage) {
        await prefs.setInt('challenge_unlocked_stage', widget.stage + 1);
      }
    }
  }

  void _showRankingRegisterDialog({bool cleared = true}) {
    TextEditingController nicknameController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('명예의 전당 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('닉네임을 입력하여 기록을 남기세요!', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '닉네임 (최대 10자)',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    counterStyle: const TextStyle(color: Colors.white54),
                  ),
                  maxLength: 10,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  final nickname = nicknameController.text.trim();
                  if (nickname.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("닉네임을 입력해주세요!")));
                    return;
                  }

                  setDialogState(() => isSaving = true);
                  
                  try {
                    // 리더보드 서비스 호출
                    // 챌린지 모드는 'challenge' 난이도로, 점수는 score 필드에, displayTime에는 스테이지 정보를 저장
                    String statusText = cleared ? 'Stage ${widget.stage}' : 'Stage ${widget.stage} (Fail)';
                    await LeaderboardService().saveScore(
                      nickname: nickname,
                      seconds: 0, // 챌린지는 시간이 아닌 점수 기준
                      score: _score,
                      displayTime: statusText, // 스테이지 및 클리어 여부 정보 저장
                      difficulty: 'challenge',
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // 등록 다이얼로그 닫기
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("랭킹이 등록되었습니다!")));
                      // 랭킹 화면으로 이동할 수도 있음 (선택 사항)
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("랭킹 등록 실패. 네트워크를 확인하세요.")));
                      setDialogState(() => isSaving = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                  : const Text('등록'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showClearDialog(int timeBonus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            Text(
              'Stage ${widget.stage} Clear!',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreRow('페어 점수', '${_pairsCleared} × 100', _pairsCleared * 100),
            const SizedBox(height: 8),
            _buildScoreRow('시간 보너스', '${_remainingSeconds}초 × 100', timeBonus),
            const Divider(color: Colors.white24, height: 20),
            _buildScoreRow('총점', '', _score, isTotal: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               // 랭킹 등록 다이얼로그 띄우기 (현재 다이얼로그 유지한 채로 위에 띄움)
               _showRankingRegisterDialog(cleared: true);
            },
            child: const Text('랭킹 등록', style: TextStyle(color: Colors.blueAccent)),
          ),
          if (widget.stage < 20)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeGameScreen(stage: widget.stage + 1),
                  ),
                );
              },
              child: const Text(
                '다음 단계',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // game screen
            },
            child: const Text(
              '메뉴로',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⏰', style: TextStyle(fontSize: 32)),
            SizedBox(width: 10),
            Text(
              'Time Over!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '시간이 부족했습니다.\n최종 점수: $_score점', // 점수 표시 추가
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
               _showRankingRegisterDialog(cleared: false);
            },
            icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
            label: const Text('리더보드 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.withOpacity(0.8),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChallengeGameScreen(stage: widget.stage),
                ),
              );
            },
            child: const Text(
              '재도전',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // game screen
            },
            child: const Text(
              '메뉴로',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String detail, int value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isTotal ? Colors.amber : Colors.white70,
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (detail.isNotEmpty)
              Text(
                detail,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
          ],
        ),
        Text(
          '${value.toString()}점',
          style: TextStyle(
            color: isTotal ? Colors.amber : Colors.white,
            fontSize: isTotal ? 22 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pathClearTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildItemControls(), // 상단으로 이동
              Expanded(
                child: _buildGameBoard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildItemControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Colors.black12, // 배경색 연하게
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        children: [
          _buildActionButton(
            icon: Icons.shuffle,
            label: '셔플',
            count: _shuffleCount,
            onTap: _onShuffle,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            icon: Icons.lightbulb_outline,
            label: '힌트',
            count: _hintCount,
            onTap: _onHint,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
    required Color color,
  }) {
    final bool isEnabled = count > 0;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 패딩 절반 축소
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15), // 반지름 축소
          border: Border.all(
            color: isEnabled ? color : Colors.grey.withOpacity(0.3),
            width: 1.5, // 테두리 두께 축소
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isEnabled ? color : Colors.grey, size: 16), // 아이콘 크기 축소 (24 -> 16)
            const SizedBox(width: 6),
            Text(
              '$label $count',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontSize: 13, // 폰트 크기 축소 (18 -> 13)
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stage ${widget.stage}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_config.tileCount}개 타일',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 타이머
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _remainingSeconds <= 30
                  ? Colors.red.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _remainingSeconds <= 30 ? Colors.red : Colors.white24,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _remainingSeconds <= 30 ? Colors.red : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    color: _remainingSeconds <= 30 ? Colors.red : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 점수
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Text(
              '$_score',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 타일 크기 계산
            double totalWidth = constraints.maxWidth;
            double gridWidth = totalWidth - 20; // padding 10
            int crossAxisSpacing = 2;
            _tileWidth = (gridWidth - (_cols - 1) * crossAxisSpacing) / _cols;
            _tileHeight = _tileWidth / 0.75;
            
            return Stack(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10), // 타일 크기 확대를 위해 패딩 축소 (40 -> 10)
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols, // 동적 컬럼 수 사용 (40타일 -> 6열)
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _board.length,
                  itemBuilder: (context, index) {
                    return _buildTile(index);
                  },
                ),
                
                Positioned.fill(
                   child: IgnorePointer(
                     child: ListenableBuilder( // 화면 갱신을 위해 ListenableBuilder 사용 (선택된 경로 변경 감지용이 필요하지만 여기선 setState로 리빌드됨)
                       listenable: _particleSystem, // 더미 listenable (실제로는 부모 setState로 리빌드)
                       builder: (context, child) {
                         if (_selectedPath != null && _selectedPath!.isNotEmpty) {
                           return CustomPaint(
                             painter: NeonPathPainter(
                               _selectedPath!, 
                               _cols, 
                               _tileWidth + 2, // width + spacing (crossAxisSpacing=2)
                               _tileHeight + 2, 
                               paddingX: 10, // GridView padding
                               paddingY: 10,
                               adjustForBorder: false, // Challenge 모드는 전체 렌더링이므로 오프셋 불필요
                             ),
                           );
                         }
                         return const SizedBox.shrink();
                       },
                     ),
                   ),
                ),

                // 파티클 오버레이
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: _particleSystem,
                    builder: (context, child) {
                      return ParticleOverlay(
                        system: _particleSystem,
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }


  void _autoShuffle() {
    setState(() {
      // 셔플 로직 (아이템 차감 안 함)
      // BLOCK은 위치 고정, 일반 타일만 셔플
      List<String> remainingTiles = _board.where((t) => t.isNotEmpty && t != 'BLOCK').toList();
      remainingTiles.shuffle();
      
      int idx = 0;
      for (int i = 0; i < _board.length; i++) {
        if (_board[i].isNotEmpty && _board[i] != 'BLOCK') {
          _board[i] = remainingTiles[idx++];
        }
      }
      _selectedIndex = -1;
      _selectedPath = null;
    });
  }
}

