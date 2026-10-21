import 'package:flutter/material.dart';

/// A compact visual milestone: levels 1–5 are the start, 6–10 the strong stage.
class ProgressJourney extends StatelessWidget {
  const ProgressJourney({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          'Путь силы: уровни 1–5 — Старт, уровни 6–10 — Силач. '
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
                    '1–5 · Старт',
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

    canvas.drawCircle(const Offset(80, 19), 11, slimPaint);
    canvas.drawPath(
      Path()
        ..moveTo(69, 35)
        ..lineTo(91, 35)
        ..lineTo(88, 76)
        ..lineTo(72, 76)
        ..close(),
      slimPaint,
    );
    final slimLimbs = Paint()
      ..color = slimPaint.color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(72, 44), const Offset(61, 69), slimLimbs);
    canvas.drawLine(const Offset(88, 44), const Offset(99, 69), slimLimbs);
    canvas.drawLine(const Offset(76, 75), const Offset(71, 100), slimLimbs);
    canvas.drawLine(const Offset(84, 75), const Offset(89, 100), slimLimbs);

    canvas.drawCircle(const Offset(240, 18), 12, strongPaint);
    canvas.drawPath(
      Path()
        ..moveTo(211, 38)
        ..lineTo(225, 33)
        ..lineTo(255, 33)
        ..lineTo(269, 38)
        ..lineTo(255, 75)
        ..lineTo(225, 75)
        ..close(),
      strongPaint,
    );
    final strongLimbs = Paint()
      ..color = strongPaint.color
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(217, 42), const Offset(205, 67), strongLimbs);
    canvas.drawLine(const Offset(263, 42), const Offset(275, 67), strongLimbs);
    canvas.drawLine(const Offset(233, 75), const Offset(229, 100), strongLimbs);
    canvas.drawLine(const Offset(247, 75), const Offset(251, 100), strongLimbs);

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

  @override
  bool shouldRepaint(covariant _JourneyPainter oldDelegate) =>
      strongActive != oldDelegate.strongActive;
}
