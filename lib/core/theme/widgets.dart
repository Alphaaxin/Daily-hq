import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Haptics, in one place so they stay consistent.
class Haptic {
  static void tap() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void win() => HapticFeedback.mediumImpact();
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.hero = false});

  final Widget child;
  final EdgeInsets padding;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(N.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(N.r),
            border: Border.all(color: hero ? const Color(0x38D9B46A) : N.line),
            color: hero ? null : N.surface,
            gradient: hero
                ? const LinearGradient(
                    begin: Alignment(-0.6, -1),
                    end: Alignment(0.6, 1),
                    colors: [Color(0x29D9B46A), Color(0x06FFFFFF)],
                    stops: [0, .55],
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  const CardHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(title, style: N.h2)),
        ?trailing,
      ],
    ),
  );
}

/// Thin divider + spacing between sub-sections of a card.
class SubSection extends StatelessWidget {
  const SubSection({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.only(top: 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: N.line)),
    ),
    child: child,
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: N.eyebrow.copyWith(color: color));
}

/// Text painted with the gold gradient.
class GoldText extends StatelessWidget {
  const GoldText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (r) => N.goldGradient.createShader(r),
    child: Text(text, style: style),
  );
}

enum BtnKind { primary, night, raise, ghost, danger }

class NButton extends StatelessWidget {
  const NButton(this.label, {super.key, this.onTap, this.kind = BtnKind.primary, this.icon, this.expand = false});

  final String label;
  final VoidCallback? onTap;
  final BtnKind kind;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final (Gradient? g, Color? c, Color fg, Color border) = switch (kind) {
      BtnKind.primary => (N.goldGradient, null, N.goldInk, Colors.transparent),
      BtnKind.night => (N.nightGradient, null, N.night, const Color(0x40A0AAFF)),
      BtnKind.raise => (null, N.raise, N.ink, N.line),
      BtnKind.ghost => (null, Colors.transparent, N.ink, N.line),
      BtnKind.danger => (null, N.badSoft, N.bad, Colors.transparent),
    };
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: fg),
          ),
        ),
      ],
    );
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: g,
          color: c,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: kind == BtnKind.primary && enabled
              ? const [BoxShadow(color: Color(0x38D9B46A), blurRadius: 18, offset: Offset(0, 6))]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled
                ? () {
                    Haptic.light();
                    onTap!();
                  }
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class IconBtn extends StatelessWidget {
  const IconBtn(this.icon, {super.key, required this.onTap, this.color, this.label});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: N.raise,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: N.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Haptic.tap();
          onTap();
        },
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 20, color: color ?? N.ink)),
      ),
    ),
  );
}

class GoldBar extends StatelessWidget {
  const GoldBar(this.value, {super.key, this.color, this.height = 6});
  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: Container(
      height: height,
      color: const Color(0x12FFFFFF),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: color == null ? N.goldGradient : null,
              color: color,
              boxShadow: [BoxShadow(color: (color ?? N.gold).withValues(alpha: .45), blurRadius: 10)],
            ),
          ),
        ),
      ),
    ),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.hot = false, this.color, this.mono = false});
  final String text;
  final bool hot;
  final Color? color;
  final bool mono;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: hot ? N.goldSoft : N.raise,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: hot ? Colors.transparent : N.line),
    ),
    child: Text(
      text,
      style: (mono ? N.num(12) : const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)).copyWith(
        color: color ?? (hot ? N.gold : N.muted),
      ),
    ),
  );
}

class NChip extends StatelessWidget {
  const NChip(this.label, {super.key, required this.on, required this.onTap, this.color});
  final String label;
  final bool on;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? N.gold;
    return Material(
      color: on ? c.withValues(alpha: .13) : N.raise,
      shape: StadiumBorder(side: BorderSide(color: on ? c : N.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          Haptic.tap();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? (color ?? N.goldHi) : N.muted),
          ),
        ),
      ),
    );
  }
}

/// Life Score ring with the gold gradient arc.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 96, this.label = 'Life score'});
  final int score;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label $score of 100',
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: score / 100),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(v * 100).round()}', style: N.num(26)),
                const SizedBox(height: 2),
                Text(label.toUpperCase(), style: N.eyebrow.copyWith(fontSize: 9)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.5;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0x12FFFFFF),
    );
    if (v <= 0) return;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [N.goldLo, N.gold, N.goldHi],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.v != v;
}

class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: N.line),
    ),
    child: Text(text, textAlign: TextAlign.center, style: N.small),
  );
}

/// Opens a Nizam-styled bottom sheet that resizes with the keyboard.
Future<T?> showNSheet<T>(BuildContext context, Widget Function(BuildContext) builder) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
    child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), child: builder(ctx)),
  ),
);

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: N.ink)),
      ),
    );
}
