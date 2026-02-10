import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'audio_manager.dart';

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
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/image/title.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // 게임 시작 투명 버튼
          // 위치는 하단부 중앙 정도로 가정하고 넓게 잡음
          // 필요하다면 Positioned 좌표를 세밀하게 조정 가능
          Positioned(
            bottom: 50, // 하단에서 50px 위
            left: 0,
            right: 0,
            height: 150, // 높이 150px 영역
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: Container(
                  width: 300, // 너비 300px
                  height: 100, // 높이 100px
                  color: Colors.transparent, // 투명
                  // 디버그용으로 색상을 넣고 싶다면 아래 주석 해제
                  // color: Colors.red.withOpacity(0.3), 
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
