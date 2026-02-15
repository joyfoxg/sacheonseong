enum LayoutPattern {
  pyramid,      // 피라미드형
  diamond,      // 다이아몬드형
  stairs,       // 계단형
  spiral,       // 나선형
  cluster,      // 랜덤 클러스터
}

class StageConfig {
  final int stage;
  final int tileCount;
  final int timeLimitSeconds;
  final int obstacleCount;
  final LayoutPattern pattern;

  const StageConfig({
    required this.stage,
    required this.tileCount,
    required this.timeLimitSeconds,
    required this.obstacleCount,
    required this.pattern,
  });
}

// 20단계 스테이지 설정
class ChallengeStages {
  static const List<StageConfig> stages = [
    // 1-5단계: 40개 타일, 장애물 0개
    StageConfig(stage: 1, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.pyramid),
    StageConfig(stage: 2, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.diamond),
    StageConfig(stage: 3, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.stairs),
    StageConfig(stage: 4, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.spiral),
    StageConfig(stage: 5, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.cluster),
    
    // 6-10단계: 60개 타일, 장애물 2개
    StageConfig(stage: 6, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.pyramid),
    StageConfig(stage: 7, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.diamond),
    StageConfig(stage: 8, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.stairs),
    StageConfig(stage: 9, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.spiral),
    StageConfig(stage: 10, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.cluster),
    
    // 11-15단계: 80개 타일, 장애물 4개
    StageConfig(stage: 11, tileCount: 80, timeLimitSeconds: 300, obstacleCount: 4, pattern: LayoutPattern.pyramid),
    StageConfig(stage: 12, tileCount: 80, timeLimitSeconds: 300, obstacleCount: 4, pattern: LayoutPattern.diamond),
    StageConfig(stage: 13, tileCount: 80, timeLimitSeconds: 300, obstacleCount: 4, pattern: LayoutPattern.stairs),
    StageConfig(stage: 14, tileCount: 80, timeLimitSeconds: 300, obstacleCount: 4, pattern: LayoutPattern.spiral),
    StageConfig(stage: 15, tileCount: 80, timeLimitSeconds: 300, obstacleCount: 4, pattern: LayoutPattern.cluster),
    
    // 16-20단계: 100개 타일, 장애물 8개
    StageConfig(stage: 16, tileCount: 100, timeLimitSeconds: 300, obstacleCount: 8, pattern: LayoutPattern.pyramid),
    StageConfig(stage: 17, tileCount: 100, timeLimitSeconds: 300, obstacleCount: 8, pattern: LayoutPattern.diamond),
    StageConfig(stage: 18, tileCount: 100, timeLimitSeconds: 300, obstacleCount: 8, pattern: LayoutPattern.stairs),
    StageConfig(stage: 19, tileCount: 100, timeLimitSeconds: 300, obstacleCount: 8, pattern: LayoutPattern.spiral),
    StageConfig(stage: 20, tileCount: 100, timeLimitSeconds: 300, obstacleCount: 8, pattern: LayoutPattern.cluster),
  ];

  static StageConfig getStage(int stageNumber) {
    if (stageNumber < 1 || stageNumber > 20) {
      throw ArgumentError('Stage number must be between 1 and 20');
    }
    return stages[stageNumber - 1];
  }
}
