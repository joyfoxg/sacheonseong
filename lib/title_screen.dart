import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'audio_manager.dart';
import 'leaderboard_screen.dart';
import 'widgets/ranking_marquee.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  void initState() {
    super.initState();
    _startBgm();
  }

  void _startBgm() async {
    final audioManager = AudioManager();
    await audioManager.init();
    await audioManager.playBgm();
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

          // 중앙 실시간 랭킹 전광판 (고급형)
          const Positioned(
            top: 150, 
            left: 0,
            right: 0,
            child: Center(
              child: RankingMarquee(),
            ),
          ),
          
          // 게임 시작 투명 버튼
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            height: 150,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: Container(
                  width: 300,
                  height: 100,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
