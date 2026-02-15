import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'challenge_stage_config.dart';
import 'challenge_game_screen.dart';

class ChallengeModeScreen extends StatefulWidget {
  const ChallengeModeScreen({super.key});

  @override
  State<ChallengeModeScreen> createState() => _ChallengeModeScreenState();
}

class _ChallengeModeScreenState extends State<ChallengeModeScreen> {
  int _unlockedStage = 1;  // 해금된 최고 단계
  Map<int, int> _highScores = {}; // 각 단계별 최고 점수

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedStage = prefs.getInt('challenge_unlocked_stage') ?? 1;
      
      // 각 단계별 최고 점수 로드
      for (int i = 1; i <= 20; i++) {
        _highScores[i] = prefs.getInt('challenge_stage_${i}_score') ?? 0;
      }
    });
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
              // 헤더
              _buildHeader(),
              
              // 스테이지 그리드
              Expanded(
                child: _buildStageGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 8 -> 4 최소화
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24), // 28 -> 24
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8), // 10 -> 8
          const Text(
            '🔥 챌린지 모드',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // 28 -> 24
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // 상단 패딩 0으로
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85, // 비율 복원 (1.4 -> 0.85) - 정상적인 크기로
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final stage = index + 1;
        final isUnlocked = stage <= _unlockedStage;
        final config = ChallengeStages.getStage(stage);
        final highScore = _highScores[stage] ?? 0;
        
        return _buildStageCard(stage, config, isUnlocked, highScore);
      },
    );
  }

  Widget _buildStageCard(int stage, StageConfig config, bool isUnlocked, int highScore) {
    return GestureDetector(
      onTap: isUnlocked ? () => _startStage(stage) : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    Colors.purple.withOpacity(0.6),
                    Colors.deepPurple.withOpacity(0.8),
                  ]
                : [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUnlocked ? Colors.amber.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? Colors.purple.withOpacity(0.3) : Colors.black26,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stage',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12, // 10 -> 12 복원
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$stage',
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.4),
                fontSize: 32, // 28 -> 32 복원
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8), // 4 -> 8 복원
            
            // 타일 수
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apps,
                  color: Colors.white.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${config.tileCount}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // 최고 점수
            if (highScore > 0) ...[
              const SizedBox(height: 4),
              Text(
                '🏆 ${_formatScore(highScore)}',
                style: TextStyle(
                  color: Colors.amber[300],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            // 잠금 아이콘
            if (!isUnlocked) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.lock,
                color: Colors.white.withOpacity(0.4),
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return score.toString();
  }

  void _startStage(int stage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeGameScreen(stage: stage),
      ),
    ).then((_) {
      // 돌아왔을 때 진행 상태 리로드
      _loadProgress();
    });
  }
}
