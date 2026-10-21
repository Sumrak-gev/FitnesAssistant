import 'package:flutter/material.dart';

/// Compact, code-drawn flag used to identify the white-and-blue palette.
class IsraelFlagIcon extends StatelessWidget {
  const IsraelFlagIcon({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Флаг Израиля',
    child: const SizedBox(
      width: 24,
      height: 16,
      child: CustomPaint(painter: _IsraelFlagPainter()),
    ),
  );
}

class _IsraelFlagPainter extends CustomPainter {
  const _IsraelFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF0038B8);
    final white = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
      white,
    );
    final stripeHeight = size.height * .12;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .2, size.width, stripeHeight),
      blue,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .68, size.width, stripeHeight),
      blue,
    );
    final star = Paint()
      ..color = blue.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * .07
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = size.height * .19;
    final dy = size.height * .2;
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - dy)
        ..lineTo(cx - dx, cy + dy * .55)
        ..lineTo(cx + dx, cy + dy * .55)
        ..close(),
      star,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + dy)
        ..lineTo(cx - dx, cy - dy * .55)
        ..lineTo(cx + dx, cy - dy * .55)
        ..close(),
      star,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
