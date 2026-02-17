import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; // 1.0 (생성) -> 0.0 (소멸)
  double decay;
  double gravity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    required this.decay,
    this.gravity = 0.0,
  });
}

class ParticleSystem extends ChangeNotifier {
  List<Particle> particles = [];
  final Random _random = Random();

  void addExplosion(Offset position, {int count = 40, List<Color>? colors}) {
    for (int i = 0; i < count; i++) {
      double angle = _random.nextDouble() * 2 * pi;
      double speed = _random.nextDouble() * 8 + 4; // 속도 증가 (4 ~ 12)
      
      Color color = colors != null && colors.isNotEmpty 
          ? colors[_random.nextInt(colors.length)]
          : [
              Colors.redAccent[200]!, Colors.orangeAccent[200]!, Colors.amberAccent[200]!,
              Colors.greenAccent[200]!, Colors.lightBlueAccent[200]!, Colors.blueAccent[200]!,
              Colors.purpleAccent[200]!, Colors.pinkAccent[200]!, Colors.cyanAccent[200]!,
              Colors.limeAccent[200]!, Colors.tealAccent[200]!, Colors.indigoAccent[200]!,
            ][_random.nextInt(12)]; // 강렬한 액센트 컬러 사용

      particles.add(Particle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
        size: _random.nextDouble() * 12 + 10, // 크기 증가 (10 ~ 22)
        life: 1.0,
        decay: _random.nextDouble() * 0.02 + 0.01, // 감소율 약간 줄임 (조금 더 오래 지속)
        gravity: 0.2, // 중력 약간 증가 (무거운 느낌)
      ));
    }
    notifyListeners();
  }

  void update() {
    if (particles.isEmpty) return;

    for (int i = particles.length - 1; i >= 0; i--) {
      var p = particles[i];
      p.position += p.velocity;
      p.velocity += Offset(0, p.gravity); // 중력 적용
      p.velocity *= 0.94; // 마찰력 (속도 감소) 약간 증가 (폭발 후 멈추는 느낌)
      p.life -= p.decay;
      p.size *= 0.96; // 크기 점차 감소

      if (p.life <= 0 || p.size < 0.5) {
        particles.removeAt(i);
      }
    }
    notifyListeners();
  }
}

class ParticleOverlay extends StatelessWidget {
  final ParticleSystem system;
  final Size size;

  const ParticleOverlay({
    Key? key,
    required this.system,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _ParticlePainter(system.particles),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      var paint = Paint()
        ..color = p.color.withOpacity(max(0, p.life))
        ..style = PaintingStyle.fill;

      // 원형 파티클
      canvas.drawCircle(p.position, p.size, paint);
      
      // 별 모양 파티클 (일부)
      // if (p.size > 6) {
      //   _drawStar(canvas, p.position, p.size, paint);
      // }
    }
  }

  // void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
  //   // 별 그리기 로직 (생략 - 성능 위해 원으로 통일)
  // }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return true; // 항상 다시 그림 (애니메이션)
  }
}
