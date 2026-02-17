import 'package:flutter/material.dart';

class NeonPathPainter extends CustomPainter {
  final List<int> path;
  final int cols;
  final double tileWidth;
  final double tileHeight;
  final double paddingX; 
  final double paddingY;
  final bool adjustForBorder; // 테두리 오프셋(-1) 적용 여부

  NeonPathPainter(
    this.path, 
    this.cols, 
    this.tileWidth, 
    this.tileHeight, 
    {
      this.paddingX = 0, 
      this.paddingY = 0,
      this.adjustForBorder = true, // 기본값: GameScreen용 (테두리 제외 렌더링)
    }
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    // 경로 생성
    Path drawPath = Path();
    
    Offset getCenter(int index) {
      int r = index ~/ cols;
      int c = index % cols;
      
      // GameScreen: 내부만 그리므로 전체 인덱스에서 테두리(-1)를 빼야 함.
      // ChallengeGameScreen: 전체를 다 그리므로 인덱스 그대로 사용.
      double colIndex = adjustForBorder ? (c - 1).toDouble() : c.toDouble();
      double rowIndex = adjustForBorder ? (r - 1).toDouble() : r.toDouble();

      double x = colIndex * tileWidth + tileWidth / 2 + paddingX;
      double y = rowIndex * tileHeight + tileHeight / 2 + paddingY;
      
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
