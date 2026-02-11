import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreEntry {
  final String id;
  final String nickname;
  final int seconds;
  final String displayTime;
  final DateTime createdAt;

  ScoreEntry({
    required this.id,
    required this.nickname,
    required this.seconds,
    required this.displayTime,
    required this.createdAt,
  });

  factory ScoreEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScoreEntry(
      id: doc.id,
      nickname: data['nickname'] ?? 'Unknown',
      seconds: data['seconds'] ?? 0,
      displayTime: data['displayTime'] ?? '00:00',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'nickname': nickname,
        'seconds': seconds,
        'displayTime': displayTime,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving score: $e');
      rethrow;
    }
  }

  // 상위 n개 기록 가져오기
  Future<List<ScoreEntry>> getTopScores({int limit = 20}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('seconds', descending: false) // 시간이 짧은 순서대로
          .orderBy('createdAt', descending: false) // 같은 시간이면 먼저 달성한 순서
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScoreEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting top scores: $e');
      return [];
    }
  }
}
