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
  Timer? _fadeTimer;
  bool _isLoading = true;
  double _opacity = 1.0; // 투명도 상태
  bool _isUserInteracting = false;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _loadScores();
    _startFadeCycle(); // 페이드 주기 시작
  }

  // 페이드 인/아웃 주기 제어
  void _startFadeCycle() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(seconds: 13), (timer) async {
      if (!mounted || _isUserInteracting) return;
      
      // 1. 5초 대기 (보여줌) - 기존 7초에서 단축
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted || _isUserInteracting) return;
      
      // 2. 스르르 사라짐 (2초 소요)
      setState(() => _opacity = 0.0);
      
      // 3. 사라진 상태로 4초 대기
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || _isUserInteracting) return;
      
      // 4. 다시 스르르 나타남 (2초 소요)
      setState(() => _opacity = 1.0);
    });
  }

  // 터치 및 상호작용 시 자동 스크롤 및 페이드 리셋
  void _onInteractionStart() {
    _isUserInteracting = true;
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    
    if (_opacity < 1.0) {
      setState(() => _opacity = 1.0);
    }
  }

  void _onInteractionEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isUserInteracting = false);
        if (_scores.length >= 10) {
          _startAutoScroll();
        }
        _startFadeCycle();
      }
    });
  }

  Future<void> _loadScores() async {
    try {
      final scores = await _service.getTopScores(limit: 20); // 10개 이상 스크롤을 위해 더 많이 가져옴
      if (mounted) {
        setState(() {
          _scores = scores;
          _isLoading = false;
        });
        if (_scores.length >= 10) {
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
    if (_isUserInteracting) return;
    
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients && !_isUserInteracting) {
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
    _fadeTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_scores.isEmpty) return const SizedBox.shrink();

    // 10등 이상일 때만 무한 루프처럼 보이게 리스트 반복
    final displayList = _scores.length >= 10 ? [..._scores, ..._scores] : _scores;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _onInteractionStart();
        } else if (notification is ScrollEndNotification) {
          _onInteractionEnd();
        }
        return false;
      },
      child: GestureDetector(
        onTapDown: (_) => _onInteractionStart(),
        onTapUp: (_) => _onInteractionEnd(),
        onTapCancel: () => _onInteractionEnd(),
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2), // 스르르 나타나고 사라지는 시간
          opacity: _opacity,
          curve: Curves.easeInOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 320,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "🏆 실시간 명예의 전당",
                        style: TextStyle(
                          color: Colors.amber[100],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.5,
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
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(), // 수동 스크롤 허용
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final entry = displayList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${(index % _scores.length) + 1}위",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(color: Colors.black45, offset: const Offset(1, 1), blurRadius: 1),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      entry.nickname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(color: Colors.black54, offset: const Offset(1, 1), blurRadius: 3),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  entry.displayTime,
                                  style: TextStyle(
                                    color: Colors.amber[300],
                                    fontSize: 15,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(color: Colors.black54, offset: const Offset(1, 1), blurRadius: 2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
