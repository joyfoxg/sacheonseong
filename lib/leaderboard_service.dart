import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreEntry {
  final String id;
  final String nickname;
  final int seconds;
  final int score; // 챌린지 모드 점수 (추가)
  final String displayTime;
  final DateTime createdAt;
  final String difficulty;

  ScoreEntry({
    required this.id,
    required this.nickname,
    required this.seconds,
    this.score = 0,
    required this.displayTime,
    required this.createdAt,
    required this.difficulty,
  });

  factory ScoreEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScoreEntry(
      id: doc.id,
      nickname: data['nickname'] ?? 'Unknown',
      seconds: data['seconds'] ?? 0,
      score: data['score'] ?? 0,
      displayTime: data['displayTime'] ?? '00:00',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      difficulty: data['difficulty'] ?? 'normal',
    );
  }
}

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'scores';

  // 기록 저장
  Future<void> saveScore({
    required String nickname,
    required int seconds,
    required String displayTime,
    required String difficulty,
    int score = 0, // 챌린지 모드 점수
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'nickname': nickname,
        'seconds': seconds,
        'score': score,
        'displayTime': displayTime,
        'difficulty': difficulty,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving score: $e');
      rethrow;
    }
  }

  // 상위 n개 기록 가져오기
  Future<List<ScoreEntry>> getTopScores({int limit = 20, String? difficulty}) async {
    try {
      Query query = _firestore.collection(_collectionPath);

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      // 챌린지 모드는 점수(score) 내림차순, 나머지는 시간(seconds) 오름차순
      if (difficulty == 'challenge') {
        query = query.orderBy('score', descending: true);
      } else {
        query = query.orderBy('seconds', descending: false);
      }

      QuerySnapshot querySnapshot = await query
          .orderBy('createdAt', descending: false) // 같은 점수/시간이면 먼저 달성한 순서
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScoreEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting top scores: $e');
      rethrow; // UI에서 에러를 잡을 수 있도록 던짐
    }
  }
}
