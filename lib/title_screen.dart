import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'game_screen.dart';
import 'audio_manager.dart';
import 'leaderboard_screen.dart';
import 'widgets/ranking_marquee.dart';
import 'widgets/settings_dialog.dart';
import 'difficulty.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  String _version = '';
  
  @override
  void initState() {
    super.initState();
    _startBgm();
    _loadVersion();
  }

  void _startBgm() async {
    final audioManager = AudioManager();
    await audioManager.init();
    await audioManager.playBgm();
  }

  void _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Difficulty _difficulty = Difficulty.normal;

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _startGame() {
    if (_difficulty == Difficulty.challenge) {
      // 챌린지 모드는 현재 기능 구현 중
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('챌린지 모드는 현재 개발 중입니다! 다른 난이도를 선택해주세요.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.purple,
        ),
      );
      return;
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GameScreen(difficulty: _difficulty)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          
          return Stack(
            children: [
              // 배경 이미지 + 디버그용 롱탭
              Positioned.fill(
                child: GestureDetector(
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("디버그 모드: 게임 중 화면 상단을 3번 연속 클릭하면 즉시 클리어됩니다.")),
                    );
                  },
                  child: Image.asset(
                    'assets/image/title.jpg',
                    fit: BoxFit.fill, // 화면 비율에 맞게 늘려서 텍스트 위치 일관성 유지
                  ),
                ),
              ),
              
              // 리더보드 버튼 (상단 우측)
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.leaderboard, color: Colors.white, size: 36),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                    );
                  },
                ),
              ),

              // 하단 실시간 랭킹 전광판 (고급형)
              const Positioned(
                top: 280, // 제목 가림 방지를 위해 위치 하향 (기존 150)
                left: 0,
                right: 0,
                child: Center(
                  child: RankingMarquee(),
                ),
              ),
              
              

              // 난이도 선택 UI (게임 시작 버튼 상부)
              Positioned(
                top: screenHeight * 0.60, // 화면 높이의 60% 위치
                left: 0,
                right: 0,
                child: Center(
                  child: _buildDifficultySelector(screenWidth, screenHeight),
                ),
              ),

              // [PATCH] 게임 시작 버튼 (화면 비율 기반 위치)
              Positioned(
                top: screenHeight * 0.72, // 화면 높이의 72% 위치
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      width: screenWidth * 0.45, // 화면 너비의 45%
                      height: screenHeight * 0.07, // 화면 높이의 7%
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // [PATCH] 옵션 버튼 (화면 비율 기반 위치)
              Positioned(
                top: screenHeight * 0.85, // 화면 높이의 85% 위치
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showSettingsDialog(),
                    child: Container(
                      width: screenWidth * 0.35, // 화면 너비의 35%
                      height: screenHeight * 0.06, // 화면 높이의 6%
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // 버전 정보 표시 (옵션 버튼 하단)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _version,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDifficultySelector(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 화살표
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.amber, size: 32),
            onPressed: () {
              setState(() {
                final currentIndex = Difficulty.values.indexOf(_difficulty);
                final newIndex = (currentIndex - 1) % Difficulty.values.length;
                _difficulty = Difficulty.values[newIndex];
              });
              AudioManager().playSelect();
            },
          ),
          
          // 현재 난이도 표시
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDifficultyIcon(_difficulty),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  _difficulty.label,
                  style: TextStyle(
                    color: _getDifficultyColor(_difficulty),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 오른쪽 화살표
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.amber, size: 32),
            onPressed: () {
              setState(() {
                final currentIndex = Difficulty.values.indexOf(_difficulty);
                final newIndex = (currentIndex + 1) % Difficulty.values.length;
                _difficulty = Difficulty.values[newIndex];
              });
              AudioManager().playSelect();
            },
          ),
        ],
      ),
    );
  }

  String _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '😊';
      case Difficulty.normal:
        return '😐';
      case Difficulty.hard:
        return '😰';
      case Difficulty.challenge:
        return '🔥';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.normal:
        return Colors.blue;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.challenge:
        return Colors.purple;
    }
  }
}
