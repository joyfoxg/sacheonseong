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
      builder: (context) => SettingsDialog(
        currentDifficulty: _difficulty,
        onDifficultyChanged: (newDifficulty) {
          setState(() => _difficulty = newDifficulty);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                fit: BoxFit.cover,
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
          
          

          // [PATCH] 게임 시작 버튼 (정밀 위치 조정)
          Positioned(
            bottom: 120, // 높이 조정 (기존 50에서 상향)
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => GameScreen(difficulty: _difficulty)),
                  );
                },
                child: Container(
                  width: 200,
                  height: 60,
                  color: Colors.transparent, // 투명하지만 '게임 시작' 글자 영역만 차지
                ),
              ),
            ),
          ),

          // [PATCH] 옵션 버튼 (투명 영역)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _showSettingsDialog(),
                child: Container(
                  width: 150,
                  height: 50,
                  color: Colors.transparent, // 투명 버튼 (배경 이미지의 Option 텍스트 활용)
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
      ),
    );
  }
}
