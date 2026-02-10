import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_logic.dart';
import 'audio_manager.dart';

import 'title_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioManager _audioManager = AudioManager();
  late SichuanLogic _logic;
  
  // Board dimensions (padding 포함)
  static const int rows = 12; // 실제 10줄
  static const int cols = 9;  // 실제 7줄 -> 70개 타일 (35쌍)

  List<String> _board = [];
  List<int>? _selectedPath;
  int _selectedIndex = -1;
  
  // 상태 관리
  String _state = 'preparing'; // preparing, playing, finished
  
  // 아이템
  int _hintCount = 3;
  int _shuffleCount = 3;

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
      _hintCount = 3;
      _shuffleCount = 3;
      _selectedIndex = -1;
      _selectedPath = null;
    });
  }

  Future<void> _showExitDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥 터치로 닫기 불가
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 일시정지'),
          content: const Text('원하는 작업을 선택해주세요.'),
          actions: <Widget>[
            TextButton(
              child: const Text('홈으로'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TitleScreen()),
                );
              },
            ),
            TextButton(
              child: const Text('게임 계속하기'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text('게임 끝내기'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                SystemNavigator.pop(); // 앱 종료
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pathClearTimer?.cancel();
    // BGM은 TitleScreen과 공유하므로 여기서 멈추지 않음
    super.dispose();
  }

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
        backgroundColor: const Color(0xFFEFEBE9), // 따뜻한 배경색
        appBar: AppBar(
          title: const Text('사천성'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '다시 섞기 ($_shuffleCount)',
              onPressed: (_state == 'playing' && _shuffleCount > 0) ? _shuffleBoard : null,
            ),
            IconButton(
              icon: const Icon(Icons.lightbulb),
              tooltip: '힌트 ($_hintCount)',
              onPressed: (_state == 'playing' && _hintCount > 0) ? _showHint : null,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
            // 내 남은 패 & 상태
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _state == 'finished' 
                    ? "승리했습니다! 🏆"
                    : "남은 패: $myRemaining개",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 게임 보드
            Expanded(
              flex: 5,
              child: Center(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double tileWidth = constraints.maxWidth / cols;
                        double tileHeight = constraints.maxHeight / rows;
                        
                        return Stack(
                          children: [
                            // 타일 그리드
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: tileWidth / tileHeight,
                              ),
                              itemCount: rows * cols,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _handleTap(index),
                                  child: _buildTile(index),
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
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange[100] : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? Colors.orange : const Color(0xFF8D6E63),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))],
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontSize: 24,
            color: () {
              if (content.isEmpty) return Colors.black;
              int code = content.runes.first;
              
              // 만수패 (🀇 ~ 🀏): Red
              if (code >= 0x1F007 && code <= 0x1F00F) {
                return Colors.red[900];
              } 
              // 통수패 (🀐 ~ 🀘): Blue
              else if (code >= 0x1F010 && code <= 0x1F018) {
                return Colors.blue[900];
              } 
              // 삭수패 (🀙 ~ 🀡): Green
              else if (code >= 0x1F019 && code <= 0x1F021) {
                return Colors.green[800];
              }
              
              return Colors.black;
            }(),
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
       _showResultDialog('클리어 성공!! 🎉');
     } else if (_logic.isDeadlock(_board)) {
       // 더 이상 깰 수 없음 -> 자동 섞기
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("패가 꼬여서 자동으로 섞습니다!")));
       _shuffleBoard();
     }
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

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 종료'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.pop(context); // Close dialog
               // In standalone app, this might just reset or exit depending on logic.
               // For now, let's just reset the game as we don't have a menu to go back to yet.
               _startGame();
            },
            child: const Text('다시 하기'),
          ),
        ],
      ),
    );
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
      return Offset((c + 0.5) * tileWidth, (r + 0.5) * tileHeight);
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
