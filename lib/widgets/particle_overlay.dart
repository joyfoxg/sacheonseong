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

  void addExplosion(Offset position, {int count = 30, List<Color>? colors}) {
    for (int i = 0; i < count; i++) {
      double angle = _random.nextDouble() * 2 * pi;
      double speed = _random.nextDouble() * 5 + 2; // 속도 랜덤
      
      Color color = colors != null && colors.isNotEmpty 
          ? colors[_random.nextInt(colors.length)]
          // : Colors.primaries[_random.nextInt(Colors.primaries.length)];
          : Color.fromARGB(
              255, 
              200 + _random.nextInt(55), 
              200 + _random.nextInt(55), 
              200 + _random.nextInt(55)
            ); // 밝은 색 위주

      particles.add(Particle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
        size: _random.nextDouble() * 6 + 4, // 크기 4~10
        life: 1.0,
        decay: _random.nextDouble() * 0.02 + 0.015, // 감소율
        gravity: 0.1, // 약간의 중력
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
      p.velocity *= 0.95; // 마찰력 (속도 감소)
      p.life -= p.decay;
      p.size *= 0.95; // 크기 점차 감소

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
