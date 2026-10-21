import 'package:flutter/material.dart';

/// A compact visual milestone: levels 1–5 are the first stage, 6–10 the strong stage.
class ProgressJourney extends StatelessWidget {
  const ProgressJourney({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          'Путь силы: уровни 1–5 — Слабак, уровни 6–10 — Силач. '
          'Текущий уровень $level.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.primary.withValues(alpha: .78)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _JourneyPainter(strongActive: level >= 6),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '1–5 · Слабак',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: level < 6 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '6–10 · Силач',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: level >= 6
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyPainter extends CustomPainter {
  const _JourneyPainter({required this.strongActive});
  final bool strongActive;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 110);
    final halo = Paint()..color = Colors.white.withValues(alpha: .18);
    canvas.drawCircle(Offset(strongActive ? 240 : 80, 56), 47, halo);
    final slimPaint = Paint()
      ..color = Colors.white.withValues(alpha: strongActive ? .58 : 1);
    final strongPaint = Paint()
      ..color = Colors.white.withValues(alpha: strongActive ? 1 : .64);

    canvas.drawPath(_silhouette(80, strong: false), slimPaint);
    canvas.drawPath(_silhouette(240, strong: true), strongPaint);

    // The small star sits on the strong figure's chest.
    final star = Paint()
      ..color = const Color(0xFF0E4EA1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(240, 43)
        ..lineTo(233, 56)
        ..lineTo(247, 56)
        ..close(),
      star,
    );
    canvas.drawPath(
      Path()
        ..moveTo(240, 59)
        ..lineTo(233, 46)
        ..lineTo(247, 46)
        ..close(),
      star,
    );
    final arrow = Paint()
      ..color = Colors.white.withValues(alpha: .76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(145, 52)
        ..lineTo(170, 52)
        ..moveTo(162, 44)
        ..lineTo(170, 52)
        ..lineTo(162, 60),
      arrow,
    );
    canvas.restore();
  }

  Path _silhouette(double x, {required bool strong}) {
    final shoulder = strong ? 25.0 : 17.0;
    final armOuter = strong ? 40.0 : 30.0;
    final armInner = strong ? 24.0 : 17.0;
    final waist = strong ? 15.0 : 11.0;
    final legOuter = strong ? 22.0 : 18.0;
    final legInner = strong ? 7.0 : 5.0;
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(x, 18), radius: 12))
      ..moveTo(x - 6, 27)
      ..quadraticBezierTo(x, 30, x + 6, 27)
      ..cubicTo(x + shoulder, 28, x + shoulder + 4, 34, x + shoulder + 6, 43)
      ..lineTo(x + armOuter, 65)
      ..quadraticBezierTo(x + armOuter + 5, 73, x + armOuter - 1, 77)
      ..quadraticBezierTo(x + armOuter - 6, 80, x + armOuter - 10, 73)
      ..lineTo(x + armInner, 54)
      ..quadraticBezierTo(x + waist + 5, 68, x + waist, 75)
      ..lineTo(x + legOuter, 99)
      ..quadraticBezierTo(x + legOuter + 2, 106, x + legOuter - 4, 106)
      ..lineTo(x + legInner, 106)
      ..lineTo(x, 82)
      ..lineTo(x - legInner, 106)
      ..lineTo(x - legOuter + 4, 106)
      ..quadraticBezierTo(x - legOuter - 2, 106, x - legOuter, 99)
      ..lineTo(x - waist, 75)
      ..quadraticBezierTo(x - waist - 5, 68, x - armInner, 54)
      ..lineTo(x - armOuter + 10, 73)
      ..quadraticBezierTo(x - armOuter + 6, 80, x - armOuter + 1, 77)
      ..quadraticBezierTo(x - armOuter - 5, 73, x - armOuter, 65)
      ..lineTo(x - shoulder - 6, 43)
      ..cubicTo(x - shoulder - 4, 34, x - shoulder, 28, x - 6, 27)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter oldDelegate) =>
      strongActive != oldDelegate.strongActive;
}
