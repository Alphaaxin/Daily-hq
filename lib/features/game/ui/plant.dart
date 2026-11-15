import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// An original potted plant that grows through 6 stages and droops when
/// you've been away for a couple of days.
class PlantView extends StatelessWidget {
  const PlantView({super.key, required this.stage, required this.wilting, this.size = 92});
  final int stage;
  final bool wilting;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: stage.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, s, _) => CustomPaint(painter: _PlantPainter(s, wilting)),
    ),
  );
}

class _PlantPainter extends CustomPainter {
  _PlantPainter(this.s, this.wilting);
  final double s;
  final bool wilting;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Pot.
    final pot = Path()
      ..moveTo(w * .28, h * .70)
      ..lineTo(w * .72, h * .70)
      ..lineTo(w * .65, h * .97)
      ..lineTo(w * .35, h * .97)
      ..close();
    canvas.drawPath(
      pot,
      Paint()..shader = N.goldGradient.createShader(Rect.fromLTWH(w * .28, h * .70, w * .44, h * .27)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * .24, h * .66, w * .52, h * .07), const Radius.circular(4)),
      Paint()..color = N.goldLo,
    );
    // Soil.
    canvas.drawOval(Rect.fromLTWH(w * .30, h * .655, w * .40, h * .05), Paint()..color = const Color(0xFF3A2A16));
    if (s <= .05) {
      canvas.drawCircle(Offset(w * .5, h * .66), w * .03, Paint()..color = const Color(0xFF8B6B3A));
      return;
    }
    final green = wilting ? const Color(0xFF9DAA6B) : N.good;
    final stemH = h * (.10 + .10 * s.clamp(0, 5));
    final droop = wilting ? .35 : 0.0;
    final top = Offset(w * .5 + (wilting ? w * .08 : 0), h * .66 - stemH);
    final stem = Path()
      ..moveTo(w * .5, h * .66)
      ..quadraticBezierTo(w * .5, h * .66 - stemH * .6, top.dx, top.dy);
    canvas.drawPath(
      stem,
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .035
        ..strokeCap = StrokeCap.round,
    );
    void leaf(double t, bool left, double scale) {
      final p = Offset(w * .5 + (top.dx - w * .5) * t, h * .66 - stemH * t);
      final dir = left ? -1.0 : 1.0;
      final len = w * .16 * scale;
      final angle = (left ? math.pi : 0) + dir * (-.5 + droop);
      final tip = p + Offset(math.cos(angle) * len, math.sin(angle) * len);
      final ctrl = p + Offset(math.cos(angle - dir * .6) * len * .7, math.sin(angle - dir * .6) * len * .7);
      final ctrl2 = p + Offset(math.cos(angle + dir * .6) * len * .7, math.sin(angle + dir * .6) * len * .7);
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, p.dx, p.dy),
        Paint()..color = green,
      );
    }

    final leaves = (s * 2).floor().clamp(1, 8);
    for (var i = 0; i < leaves; i++) {
      leaf(.25 + .65 * (i / math.max(1, leaves)), i.isEven, .7 + .1 * math.min(i, 3));
    }
    if (s >= 4.5 && !wilting) {
      final c = top;
      final petal = Paint()..color = N.goldHi;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3;
        canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * w * .055, w * .045, petal);
      }
      canvas.drawCircle(c, w * .04, Paint()..color = N.goldLo);
    }
  }

  @override
  bool shouldRepaint(_PlantPainter o) => o.s != s || o.wilting != wilting;
}
