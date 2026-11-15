import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class NightBar {
  const NightBar({required this.label, required this.bedMin, required this.wakeMin, required this.onTarget});
  final String label;

  /// Minutes after the chart start (20:00 local).
  final int bedMin;
  final int wakeMin;
  final bool onTarget;
}

/// Bed→wake bars on a 20:00 → 16:00 axis, so late nights stay readable.
class SleepChart extends StatelessWidget {
  const SleepChart({super.key, required this.nights});
  final List<NightBar> nights;

  static const startHour = 20;
  static const spanMin = 20 * 60;

  /// Converts local minutes-of-day to chart minutes.
  static int toChart(int localMin) => (localMin - startHour * 60 + 1440) % 1440;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 170,
    child: CustomPaint(painter: _P(nights), size: Size.infinite),
  );
}

class _P extends CustomPainter {
  _P(this.nights);
  final List<NightBar> nights;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 16.0;
    final h = size.height - bottom;
    final w = size.width - left;
    final grid = Paint()
      ..color = N.line
      ..strokeWidth = 1;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final hr in [20, 0, 4, 8, 12, 16]) {
      final y = SleepChart.toChart(hr * 60) / SleepChart.spanMin * h;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
      tp.text = TextSpan(
        text: hr == 0
            ? '12a'
            : hr == 12
            ? '12p'
            : hr > 12
            ? '${hr - 12}p'
            : '${hr}a',
        style: const TextStyle(fontFamily: N.mono, fontSize: 10, color: N.muted),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, (y - tp.height / 2).clamp(0, h - tp.height)));
    }
    if (nights.isEmpty) return;
    final slot = w / nights.length;
    final bw = (slot * .55).clamp(4.0, 18.0);
    for (var i = 0; i < nights.length; i++) {
      final n = nights[i];
      final x = left + slot * i + (slot - bw) / 2;
      final y1 = n.bedMin / SleepChart.spanMin * h;
      var y2 = n.wakeMin / SleepChart.spanMin * h;
      if (y2 < y1) y2 = h; // woke after the window
      final r = RRect.fromRectAndRadius(Rect.fromLTRB(x, y1, x + bw, y2.clamp(y1 + 3, h)), const Radius.circular(5));
      canvas.drawRRect(
        r,
        Paint()
          ..shader =
              (n.onTarget ? N.goldGradient : const LinearGradient(colors: [Color(0xFFE9C062), Color(0x99E9C062)]))
                  .createShader(r.outerRect),
      );
      if (nights.length <= 14 || i % 2 == 0) {
        tp.text = TextSpan(
          text: n.label,
          style: const TextStyle(fontFamily: N.mono, fontSize: 9, color: N.muted),
        );
        tp.layout();
        tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, h + 3));
      }
    }
  }

  @override
  bool shouldRepaint(_P old) => old.nights != nights;
}
