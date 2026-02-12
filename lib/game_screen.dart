import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_logic.dart';
import 'audio_manager.dart';
import 'title_screen.dart';
import 'leaderboard_service.dart';
import 'leaderboard_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioManager _audioManager = AudioManager();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final TextEditingController _nicknameController = TextEditingController();
  late SichuanLogic _logic;
  
  // Board dimensions (padding 포함)
  static const int rows = 11; // 실제 9줄
  static const int cols = 14; // 실제 12줄 -> 9 * 12 = 108개 타일 (54쌍)

  List<String> _board = [];
  List<int>? _selectedPath;
  int _selectedIndex = -1;
  
  // 상태 관리
  String _state = 'preparing'; // preparing, playing, finished
  
  // 아이템 (최대 2회)
  int _hintCount = 2;
  int _shuffleCount = 2;

  // 타이머 및 시간 측정
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00";

  Timer? _pathClearTimer;

  @override
  void initState() {
    super.initState();

    
    _logic = SichuanLogic(rows: rows, cols: cols);
    // BGM is started in TitleScreen
    _startGame();
  }

  void _startGame() {
    setState(() {
      _board = _logic.generateBoard();
      // 풀 수 없는 판이면 다시 섞기 시도 (안정성 확보)
      int retry = 0;
      while (_logic.isDeadlock(_board) && retry < 10) {
        _board = _logic.generateBoard();
        retry++;
      }
      _state = 'playing';
      _hintCount = 2;
      _shuffleCount = 2;
      _selectedIndex = -1;
      _selectedPath = null;
      
      // 타이머 초기화 및 시작
      _stopwatch.reset();
      _stopwatch.start();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _state != 'playing') {
        timer.cancel();
        return;
      }
      setState(() {
        final duration = _stopwatch.elapsed;
        final minutes = duration.inMinutes.toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        _elapsedTime = "$minutes:$seconds";
      });
    });
  }

  Future<void> _showExitDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥 터치로 닫기 불가
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 일시정지', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('원하는 작업을 선택해주세요.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              
              // 계속하기 버튼 (가장 강조)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('게임 계속하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 홈으로 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const TitleScreen()),
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('홈으로 (메뉴)', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown[700],
                    side: BorderSide(color: Colors.brown[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 앱 종료 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: const Text('게임 끝내기', style: TextStyle(color: Colors.red, fontSize: 16)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pathClearTimer?.cancel();
    _timer?.cancel();
    _stopwatch.stop();
    // BGM은 TitleScreen과 공유하므로 여기서 멈추지 않음
    super.dispose();
  }

  int _debugClickCount = 0;

  @override
  Widget build(BuildContext context) {
    // 남은 타일 수 계산
    int myRemaining = _board.where((t) => t.isNotEmpty).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFCFB), // 더 밝고 깨끗한 배경색
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              _debugClickCount++;
              if (_debugClickCount >= 3) {
                _debugClickCount = 0;
                setState(() {
                  _state = 'finished';
                  _stopwatch.stop();
                  _timer?.cancel();
                });
                _showResultDialog('디버그 모드: 클리어 성공! 🎉\n소요 시간: $_elapsedTime');
              }
            },
            child: const Text('사천성', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown[800],
          elevation: 0,
          actions: [
            // 실시간 시간 표시
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown[200]!),
              ),
              child: Row(
                children: [
                   Icon(Icons.timer_outlined, size: 18, color: Colors.brown[700]),
                   const SizedBox(width: 4),
                   Text(
                     _elapsedTime,
                     style: TextStyle(
                       color: Colors.brown[900],
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                       fontFamily: 'monospace',
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 아이템 및 정보 영역
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 남은 패 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _state == 'finished' ? "Clear! 🏆" : "남은 패",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          "$myRemaining개",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // 아이템 버튼들
                    Row(
                      children: [
                        _buildItemButton(
                          icon: Icons.refresh,
                          label: "셔플",
                          count: _shuffleCount,
                          onPressed: (_state == 'playing' && _shuffleCount > 0) ? _shuffleBoard : null,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildItemButton(
                          icon: Icons.lightbulb_outline,
                          label: "힌트",
                          count: _hintCount,
                          onPressed: (_state == 'playing' && _hintCount > 0) ? _showHint : null,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

            // 게임 보드 (줌 및 가로/세로 스크롤 가능한 영역)
            Expanded(
              flex: 5,
              child: ClipRect(
                child: InteractiveViewer(
                  constrained: false, // 컨테이너가 화면에 눌리지 않도록 제약 해제 (왜곡 방지)
                  boundaryMargin: const EdgeInsets.all(200), // 충분한 여분 공간
                  minScale: 0.1,
                  maxScale: 2.5,
                  child: Center(
                    child: Container(
                      // 실제 타일 영역(9x12) 고정 규격으로 계산 (110x145 실제 마작패 비율)
                      width: (cols - 2) * 110.0, 
                      height: (rows - 2) * 145.0, 
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double tileWidth = 110.0;
                          const double tileHeight = 145.0;
                          
                          return Stack(
                            children: [
                              // 타일 그리드 (실제 패만 9x12로 명시적 구성)
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols - 2, // 12열
                                  mainAxisExtent: tileHeight,
                                ),
                                itemCount: (rows - 2) * (cols - 2), // 9 * 12 = 108개
                                itemBuilder: (context, index) {
                                  // 실제 데이터 인덱스 매핑 (패딩 행/열 제외)
                                  int r = index ~/ (cols - 2) + 1; // 1 ~ 9
                                  int c = index % (cols - 2) + 1;  // 1 ~ 12
                                  int boardIndex = r * cols + c;   // 14*r + c
                                  
                                  return GestureDetector(
                                    onTap: () => _handleTap(boardIndex),
                                    child: _buildTile(boardIndex),
                                  );
                                },
                              ),
                              
                              // 경로 그리기 (CustomPainter)
                              if (_selectedPath != null)
                                IgnorePointer(
                                  child: CustomPaint(
                                    size: Size(constraints.maxWidth, constraints.maxHeight),
                                    painter: _PathPainter(_selectedPath!, cols, tileWidth, tileHeight),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int index) {
    String content = _board[index];
    bool isSelected = index == _selectedIndex;
    
    if (content.isEmpty) return const SizedBox(); // 빈 공간

    return Container(
      margin: const EdgeInsets.all(0.2), // 여백 극최소화
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(1.5),
        border: Border.all(
          color: isSelected ? Colors.orange : const Color(0xFFD7CCC8),
          width: isSelected ? 1.8 : 0.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 0.5,
            offset: const Offset(0.2, 0.2),
          ),
          if (isSelected)
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 5,
              spreadRadius: 0.5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Padding(
          padding: EdgeInsets.zero, // 여백 완전 제거
          child: Image.asset(
            'assets/image/tiles/$content',
            fit: BoxFit.fill, // 셀에 꽉 차게 렌더링 (여백 제거)
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(content.contains('_') ? content.split('_').last[0] : '?', style: const TextStyle(fontSize: 8)),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (_state != 'playing') return;
    if (_board[index].isEmpty) return; // 빈 곳 클릭 무시

    // 터치 효과음 (딸깍)
    // SystemSound.play(SystemSoundType.click); // 커스텀 효과음 사용을 위해 시스템 사운드 제거
    HapticFeedback.selectionClick();

    if (_selectedIndex == -1) {
      // 첫 번째 선택
      _audioManager.playSelect();
      setState(() {
        _selectedIndex = index;
      });
    } else if (_selectedIndex == index) {
      // 같은 거 다시 클릭 -> 취소
      setState(() {
        _selectedIndex = -1;
      });
    } else {
      // 두 번째 선택 -> 매칭 시도
      List<int>? path = _logic.getPath(_board, _selectedIndex, index);
      
      if (path != null) {
        // 매칭 성공 -> 진동
        HapticFeedback.mediumImpact();
        _audioManager.playSuccess();
        
        setState(() {
          _selectedPath = path; // 경로 표시
          // 타일 제거 (잠시 보여주고 제거)
          String matchedTile = _board[_selectedIndex];
          // 즉시 제거하지 않고 타이머로 시각적 효과
          _pathClearTimer?.cancel();
          _pathClearTimer = Timer(const Duration(milliseconds: 300), () {
             if (!mounted) return;
             setState(() {
               _board[_selectedIndex] = '';
               _board[index] = '';
               _selectedIndex = -1;
               _selectedPath = null;
               
               // 남은 패 체크
               _checkGameState();
             });
          });
        });
      } else {
        // 매칭 실패 -> 선택 변경 (가벼운 진동)
        HapticFeedback.lightImpact();
        _audioManager.playFail();
        setState(() {
          _selectedIndex = index; // 실패 시 클릭한 걸 새로 선택
        });
      }
    }
  }

  void _checkGameState() {
     int remaining = _board.where((t) => t.isNotEmpty).length;
     
     if (remaining == 0) {
       _state = 'finished';
       _stopwatch.stop();
       _timer?.cancel();
       _showResultDialog('클리어 성공!! 🎉\n소요 시간: $_elapsedTime');
     } else if (_logic.isDeadlock(_board)) {
       // 더 이상 깰 수 없음 -> 자동 섞기
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("패가 꼬여서 자동으로 섞습니다!")));
       _shuffleBoard();
     }
  }

  Widget _buildItemButton({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    bool isEnabled = onPressed != null;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color.withOpacity(0.1) : Colors.grey[100],
        foregroundColor: isEnabled ? color : Colors.grey[400],
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isEnabled ? color.withOpacity(0.3) : Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Text(
              "$count",
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _shuffleBoard() {
    setState(() {
      // 현재 남은 타일들만 모아서 다시 셔플
      List<String> remainingTiles = _board.where((t) => t.isNotEmpty).toList();
      remainingTiles.shuffle();
      
      // 보드에 다시 배치
      int idx = 0;
      for (int i = 0; i < _board.length; i++) {
        if (_board[i].isNotEmpty) {
          _board[i] = remainingTiles[idx++];
        }
      }
      
      if (_shuffleCount > 0) _shuffleCount--;
      _selectedIndex = -1;
    });
  }

  void _showHint() {
    List<int>? hint = _logic.findHint(_board);
    if (hint != null) {
      if (_hintCount > 0) {
          setState(() {
            _hintCount--;
            // 힌트 타일 잠깐 깜빡이거나 표시
            // 여기선 선택 효과로 대체
            _selectedIndex = hint[0]; 
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("힌트: 선택된 패와 짝을 찾아보세요!"), duration: Duration(seconds: 1)));
          });
      }
    } else {
      // 힌트 없음 -> 섞어야 함
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("짝이 없습니다. 섞어보세요!")));
    }
  }

  // Result dialog

  void _showResultDialog(String message) {
    bool isSaving = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('게임 종료', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const Text('리더보드 등록을 위해 닉네임을 입력하세요!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: '닉네임 (최대 10자)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLength: 10,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving 
                        ? null 
                        : () async {
                          final nickname = _nicknameController.text.trim();
                          if (nickname.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("닉네임을 입력해주세요!")));
                            return;
                          }
                          
                          setDialogState(() => isSaving = true);
                          try {
                            await _leaderboardService.saveScore(
                              nickname: nickname,
                              seconds: _stopwatch.elapsed.inSeconds,
                              displayTime: _elapsedTime,
                            ).timeout(const Duration(seconds: 10), onTimeout: () {
                              throw TimeoutException("서버 응답 시간이 초과되었습니다. Firebase 설정을 확인해주세요.");
                            });
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showRanking(); // 랭킹 화면으로 이동
                            }
                          } catch (e) {
                            if (context.mounted) {
                              String errorMsg = "저장 실패";
                              if (e is TimeoutException) {
                                errorMsg = e.message ?? errorMsg;
                              } else {
                                errorMsg = "저장 중 오류가 발생했습니다. (API 활성화 여부를 확인하세요)";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                              setDialogState(() => isSaving = false);
                            }
                          }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('순위 등록하기'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isSaving ? null : () {
                         Navigator.pop(context); // Close dialog
                         _startGame();
                      },
                      child: const Text('다시 하기 (저장 안 함)'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  void _showRanking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    ).then((_) => _startGame()); // 랭킹 보고 돌아오면 다시 시작
  }

}

class _PathPainter extends CustomPainter {
  final List<int> path;
  final int cols;
  final double tileWidth;
  final double tileHeight;

  _PathPainter(this.path, this.cols, this.tileWidth, this.tileHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path drawPath = Path();
    
    Offset getCenter(int index) {
      int r = index ~/ cols;
      int c = index % cols;
      // index는 패딩 포함 인덱스이므로 9x12 캔버스 좌표를 위해 -1 오프셋 적용
      return Offset((c - 1 + 0.5) * tileWidth, (r - 1 + 0.5) * tileHeight);
    }

    drawPath.moveTo(getCenter(path[0]).dx, getCenter(path[0]).dy);
    for (int i = 1; i < path.length; i++) {
      Offset p = getCenter(path[i]);
      drawPath.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => true; 
}
