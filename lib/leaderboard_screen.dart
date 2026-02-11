import 'package:flutter/material.dart';
import 'leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardService service = LeaderboardService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('명예의 전당 (상위 20위)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
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
        child: FutureBuilder<List<ScoreEntry>>(
          future: service.getTopScores(limit: 20),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '데이터를 불러오지 못했습니다.\n(Firebase 인덱스 설정이 필요할 수 있습니다)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '상세 에러: ${snapshot.error}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final scores = snapshot.data ?? [];

            if (scores.isEmpty) {
              return const Center(child: Text('아직 등록된 기록이 없습니다. 일등을 노려보세요!'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListView.separated(
                  itemCount: scores.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = scores[index];
                    final rank = index + 1;
                    
                    Color rankColor = Colors.grey;
                    if (rank == 1) rankColor = Colors.amber;
                    else if (rank == 2) rankColor = Colors.blueGrey[300]!;
                    else if (rank == 3) rankColor = Colors.brown[400]!;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: rankColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title: Text(
                        entry.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        entry.displayTime,
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
        ),
      ),
    );
  }
}
