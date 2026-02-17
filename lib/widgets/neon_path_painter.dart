import 'package:flutter/material.dart';

class NeonPathPainter extends CustomPainter {
  final List<int> path;
  final int cols;
  final double tileWidth;
  final double tileHeight;
  final double paddingX; // 그리드 내부 패딩 오프셋 (GameScreen: 0, Challenge: 0 or calculated)
  final double paddingY;

  NeonPathPainter(this.path, this.cols, this.tileWidth, this.tileHeight, {this.paddingX = 0, this.paddingY = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    // 경로 생성
    Path drawPath = Path();
    
    Offset getCenter(int index) {
      int r = index ~/ cols;
      int c = index % cols;
      // GameScreen 로직: index는 패딩 포함 인덱스이므로 -1 오프셋 적용 (테두리가 있는 경우)
      // ChallengeGameScreen 로직: 테두리 없이 꽉 채움?
      // 이를 통일하기 위해 호출 측에서 정확한 좌표 계산 로직을 넘기거나,
      // 여기서 일반화해야 함.
      
      // GameScreen에서는 (c-1, r-1) 로직 사용.
      // ChallengeGameScreen에서는 그냥 (c, r)일 수 있음.
      // 하지만 GameScreen도 SichuanLogic을 쓰므로 (rows+2)*(cols+2) 크기임.
      // 따라서 -1 보정은 SichuanLogic을 쓴다면 필수.
      
      double x = (c - 1) * tileWidth + tileWidth / 2 + paddingX;
      double y = (r - 1) * tileHeight + tileHeight / 2 + paddingY;
      
      return Offset(x, y);
    }

    drawPath.moveTo(getCenter(path[0]).dx, getCenter(path[0]).dy);
    for (int i = 1; i < path.length; i++) {
      Offset p = getCenter(path[i]);
      drawPath.lineTo(p.dx, p.dy);
    }

    // 그라데이션 쉐이더 생성
    final Rect bounds = drawPath.getBounds();
    final Rect shaderRect = bounds.inflate(10.0);
    
    final Shader gradient = const LinearGradient(
      colors: [Colors.redAccent, Colors.orangeAccent, Colors.yellowAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(shaderRect.width > 0 ? shaderRect : const Rect.fromLTWH(0,0,100,100));

    // 1. 외곽 글로우 (빛나는 효과)
    final glowPaint = Paint()
      ..shader = gradient
      ..strokeWidth = 8 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6); // 블러 효과

    canvas.drawPath(drawPath, glowPaint);

    // 2. 내부 코어 (밝은 선)
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1); 

    canvas.drawPath(drawPath, corePaint);
  }

  @override
  bool shouldRepaint(covariant NeonPathPainter oldDelegate) => true; 
}
