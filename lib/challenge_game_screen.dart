import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart';
import 'audio_manager.dart';
import 'challenge_stage_config.dart';

class ChallengeGameScreen extends StatefulWidget {
  final int stage;

  const ChallengeGameScreen({super.key, required this.stage});

  @override
  State<ChallengeGameScreen> createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> {
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

  Timer? _pathClearTimer;

  @override
  void initState() {
    super.initState();
    _config = ChallengeStages.getStage(widget.stage);
    
    // 타일 수에 따라 그리드 크기 최적화 (타일 크기 최대화)
    if (_config.tileCount <= 40) {
      _cols = 6;  // 2배 확대 효과
      _rows = 14; // 여유 공간 확보
    } else if (_config.tileCount <= 60) {
      _cols = 8;
      _rows = 14;
    } else if (_config.tileCount <= 80) {
      _cols = 10;
      _rows = 14;
    } else {
      _cols = 12;
      _rows = 14;
    }

    _logic = SichuanLogic(
      rows: _rows,
      cols: _cols,
      tileCount: _config.tileCount,
      pattern: _config.pattern,
    );
    _remainingSeconds = _config.timeLimitSeconds;
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
            if (_board.every((tile) => tile.isEmpty)) {
              _gameOver(true);
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

      // 최고 점수 갱신
      _saveScore();

      // 클리어 다이얼로그
      _showClearDialog(timeBonus);
    } else {
      // 실패 다이얼로그
      _showFailDialog();
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('challenge_stage_${widget.stage}_score') ?? 0;
    
    if (_score > currentBest) {
      await prefs.setInt('challenge_stage_${widget.stage}_score', _score);
    }

    // 다음 단계 해금
    if (widget.stage < 20) {
      final unlockedStage = prefs.getInt('challenge_unlocked_stage') ?? 1;
      if (widget.stage >= unlockedStage) {
        await prefs.setInt('challenge_unlocked_stage', widget.stage + 1);
      }
    }
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
          '시간이 부족했습니다.\n다시 도전해보세요!',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
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
              Expanded(
                child: _buildGameBoard(),
              ),
            ],
          ),
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
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(4), // 패딩 대폭 축소 (20 -> 4)
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
      ),
    );
  }

  Widget _buildTile(int index) {
    final tile = _board[index];
    if (tile.isEmpty) return const SizedBox.shrink();

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
}
