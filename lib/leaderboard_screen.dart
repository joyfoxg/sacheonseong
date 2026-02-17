import 'package:flutter/material.dart';
import 'leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 3 -> 4
      child: Scaffold(
        appBar: AppBar(
          title: const Text('명예의 전당 (Top 20)', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.brown[700],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true, // 탭 많아지니 스크롤 가능하게
            indicatorColor: Colors.amber,
            indicatorWeight: 4,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            tabs: [
              Tab(text: "Easy"),
              Tab(text: "Normal"),
              Tab(text: "Hard"),
              Tab(text: "Challenge"), // 추가
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.brown[700]!, Colors.brown[50]!],
              stops: const [0.0, 0.3],
            ),
          ),
          child: const TabBarView(
            children: [
              _LeaderboardList(difficulty: 'easy'),
              _LeaderboardList(difficulty: 'normal'),
              _LeaderboardList(difficulty: 'hard'),
              _LeaderboardList(difficulty: 'challenge'), // 추가
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final String difficulty;
  const _LeaderboardList({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final LeaderboardService service = LeaderboardService();

    return FutureBuilder<List<ScoreEntry>>(
      future: service.getTopScores(limit: 20, difficulty: difficulty),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '데이터를 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final scores = snapshot.data ?? [];

        if (scores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 60, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  '아직 기록이 없습니다.\n첫 번째 주인공이 되어보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black45,
            color: Colors.white.withOpacity(0.95),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView.separated(
              itemCount: scores.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = scores[index];
                final rank = index + 1;
                
                Color rankColor = Colors.grey[400]!;
                double scale = 1.0;
                
                if (rank == 1) {
                  rankColor = const Color(0xFFFFD700); // Gold
                  scale = 1.2;
                } else if (rank == 2) {
                  rankColor = const Color(0xFFC0C0C0); // Silver
                  scale = 1.1;
                } else if (rank == 3) {
                  rankColor = const Color(0xFFCD7F32); // Bronze
                  scale = 1.05;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: rankColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 1)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    entry.nickname,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: difficulty == 'challenge' 
                    ? Text(entry.displayTime, style: const TextStyle(fontSize: 12, color: Colors.grey)) // 챌린지: 스테이지 정보
                    : null,
                  trailing: Text(
                    difficulty == 'challenge' 
                        ? '${entry.score}점' 
                        : entry.displayTime,
                    style: TextStyle(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
