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
          'Путь силы: уровни 1–5 — Мистер ЧМО, уровни 6–10 — Силач. '
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
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _JourneyPainter(strongActive: level >= 6),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * .25 - 53,
                      top: 2,
                      width: 106,
                      height: 106,
                      child: Opacity(
                        opacity: level >= 6 ? .64 : 1,
                        child: Image.asset(
                          'assets/mr-robot-stencil.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Трафаретный портрет Мистера Робота',
                        ),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * .75 - 53,
                      top: 2,
                      width: 106,
                      height: 106,
                      child: Opacity(
                        opacity: level >= 6 ? 1 : .64,
                        child: Image.asset(
                          'assets/strong-stencil.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Трафаретный портрет силача',
                        ),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * .75 - 11,
                      top: 72,
                      width: 22,
                      height: 26,
                      child: Image.asset(
                        'assets/star-of-david.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'Звезда Давида на груди силача',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '1–5 · Мистер ЧМО',
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
