enum LayoutPattern {
  pyramid,      // 피라미드형 (기본 직사각 채움)
  diamond,      // 다이아몬드형
  cross,        // 십자가형
  ring,         // 링/도넛형
  stairs,       // 계단형
  spiral,       // 나선형
  stripes,      // 줄무늬형
  border,       // 테두리형
  hourglass,    // 모래시계형
  zigzag,       // 지그재그형
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
    // 1-5단계: 40개 타일 (기본형)
    StageConfig(stage: 1, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.pyramid), // Rect
    StageConfig(stage: 2, tileCount: 40, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.diamond),
    StageConfig(stage: 3, tileCount: 40, timeLimitSeconds: 280, obstacleCount: 0, pattern: LayoutPattern.cross),
    StageConfig(stage: 4, tileCount: 40, timeLimitSeconds: 280, obstacleCount: 0, pattern: LayoutPattern.ring),
    StageConfig(stage: 5, tileCount: 40, timeLimitSeconds: 260, obstacleCount: 0, pattern: LayoutPattern.stairs),
    
    // 6-10단계: 50개 타일 (집중력 필요)
    StageConfig(stage: 6, tileCount: 50, timeLimitSeconds: 300, obstacleCount: 0, pattern: LayoutPattern.spiral),
    StageConfig(stage: 7, tileCount: 50, timeLimitSeconds: 280, obstacleCount: 0, pattern: LayoutPattern.stripes),
    StageConfig(stage: 8, tileCount: 50, timeLimitSeconds: 280, obstacleCount: 2, pattern: LayoutPattern.diamond),
    StageConfig(stage: 9, tileCount: 50, timeLimitSeconds: 260, obstacleCount: 2, pattern: LayoutPattern.border),
    StageConfig(stage: 10, tileCount: 50, timeLimitSeconds: 260, obstacleCount: 2, pattern: LayoutPattern.cluster),
    
    // 11-15단계: 60개 타일 (최대 개수 - 복잡한 패턴)
    StageConfig(stage: 11, tileCount: 60, timeLimitSeconds: 300, obstacleCount: 2, pattern: LayoutPattern.cross),
    StageConfig(stage: 12, tileCount: 60, timeLimitSeconds: 280, obstacleCount: 3, pattern: LayoutPattern.ring),
    StageConfig(stage: 13, tileCount: 60, timeLimitSeconds: 280, obstacleCount: 3, pattern: LayoutPattern.hourglass),
    StageConfig(stage: 14, tileCount: 60, timeLimitSeconds: 260, obstacleCount: 4, pattern: LayoutPattern.zigzag),
    StageConfig(stage: 15, tileCount: 60, timeLimitSeconds: 260, obstacleCount: 4, pattern: LayoutPattern.diamond),
    
    // 16-20단계: 60개 타일 (시간 단축 및 장애물 증가)
    StageConfig(stage: 16, tileCount: 60, timeLimitSeconds: 240, obstacleCount: 5, pattern: LayoutPattern.spiral),
    StageConfig(stage: 17, tileCount: 60, timeLimitSeconds: 230, obstacleCount: 5, pattern: LayoutPattern.stripes),
    StageConfig(stage: 18, tileCount: 60, timeLimitSeconds: 220, obstacleCount: 6, pattern: LayoutPattern.border),
    StageConfig(stage: 19, tileCount: 60, timeLimitSeconds: 210, obstacleCount: 6, pattern: LayoutPattern.stairs),
    StageConfig(stage: 20, tileCount: 60, timeLimitSeconds: 200, obstacleCount: 8, pattern: LayoutPattern.cluster),
  ];

  static StageConfig getStage(int stageNumber) {
    if (stageNumber < 1 || stageNumber > 20) {
      throw ArgumentError('Stage number must be between 1 and 20');
    }
    return stages[stageNumber - 1];
  }
}
