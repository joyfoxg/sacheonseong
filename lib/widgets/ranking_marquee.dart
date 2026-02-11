import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../leaderboard_service.dart';

class RankingMarquee extends StatefulWidget {
  const RankingMarquee({super.key});

  @override
  State<RankingMarquee> createState() => _RankingMarqueeState();
}

class _RankingMarqueeState extends State<RankingMarquee> {
  final LeaderboardService _service = LeaderboardService();
  final ScrollController _scrollController = ScrollController();
  List<ScoreEntry> _scores = [];
  Timer? _scrollTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final scores = await _service.getTopScores(limit: 10);
      if (mounted) {
        setState(() {
          _scores = scores;
          _isLoading = false;
        });
        if (_scores.isNotEmpty) {
          _startAutoScroll();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_scores.isEmpty) return const SizedBox.shrink();

    // 무한 루프처럼 보이게 하기 위해 리스트를 반복
    final displayList = [..._scores, ..._scores];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "🏆 실시간 명예의 전당",
                  style: TextStyle(
                    color: Colors.amber[100],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final entry = displayList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${(index % _scores.length) + 1}위",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                entry.nickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            entry.displayTime,
                            style: TextStyle(
                              color: Colors.amber[200],
                              fontSize: 14,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
