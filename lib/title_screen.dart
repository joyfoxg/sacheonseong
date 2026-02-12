import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'audio_manager.dart';
import 'leaderboard_screen.dart';
import 'widgets/ranking_marquee.dart';
import 'difficulty.dart';

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

  Difficulty _difficulty = Difficulty.normal;

  void _showSettingsDialog() {
    bool bgmEnabled = AudioManager().isBgmEnabled;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("게임 설정"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("배경 음악 (BGM)"),
                  value: bgmEnabled,
                  onChanged: (value) async {
                    await AudioManager().setBgmEnabled(value);
                    setDialogState(() => bgmEnabled = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("닫기"),
              ),
            ],
          );
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
          
          
          // [PATCH] 난이도 선택 (게임 시작 버튼 위)
          Positioned(
            bottom: 200, 
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown[300]!, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Difficulty>(
                    value: _difficulty,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.brown),
                    style: TextStyle(
                      color: Colors.brown[900], 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard', // 있으면 좋고 없어도 무관
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (Difficulty? newValue) {
                      if (newValue != null) {
                        setState(() => _difficulty = newValue);
                      }
                    },
                    items: Difficulty.values.map<DropdownMenuItem<Difficulty>>((Difficulty value) {
                      return DropdownMenuItem<Difficulty>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == Difficulty.easy ? Icons.sentiment_satisfied_alt :
                              value == Difficulty.normal ? Icons.sentiment_neutral :
                              Icons.sentiment_very_dissatisfied,
                              color: value == Difficulty.easy ? Colors.green :
                                     value == Difficulty.normal ? Colors.blue :
                                     Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(value.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
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

          // [PATCH] 옵션 버튼 (정밀 위치 조정)
          Positioned(
            bottom: 40, // 시작 버튼 아래 위치
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _showSettingsDialog(),
                child: Container(
                  width: 150,
                  height: 50,
                  color: Colors.transparent, // 투명하지만 '옵션' 글자 영역만 차지
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
