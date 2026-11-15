import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/gamification/data/xp_repo.dart';
import 'theme/tokens.dart';
import 'theme/widgets.dart';

/// Fire-and-forget confetti for big wins (level up, water goal, all habits).
class Celebrator {
  final _c = StreamController<String>.broadcast();
  Stream<String> get stream => _c.stream;
  void celebrate(String message) => _c.add(message);
}

final celebratorProvider = Provider((ref) => Celebrator());

/// Wraps the app: shows "+XP" toasts and confetti.
class CelebrationLayer extends ConsumerStatefulWidget {
  const CelebrationLayer({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<CelebrationLayer> createState() => _CelebrationLayerState();
}

class _CelebrationLayerState extends ConsumerState<CelebrationLayer> {
  final _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
  final _subs = <StreamSubscription>[];
  String? _toast;
  int _toastId = 0;
  int _pending = 0;
  Timer? _flush;

  @override
  void initState() {
    super.initState();
    _subs.add(
      ref.read(xpRepoProvider).events.listen((e) {
        if (e.delta > 0) {
          // Coalesce rapid awards (e.g. habit + all-habits bonus) into one toast.
          _pending += e.delta;
          _flush?.cancel();
          _flush = Timer(const Duration(milliseconds: 120), () {
            _show('+$_pending XP');
            _pending = 0;
          });
        }
        if (e.levelUp != null) {
          _boom('Level ${e.levelUp!.level} · ${e.levelUp!.name}!');
        }
      }),
    );
    _subs.add(ref.read(celebratorProvider).stream.listen(_boom));
  }

  void _boom(String msg) {
    Haptic.win();
    _confetti.play();
    Future.delayed(const Duration(milliseconds: 350), () => _show(msg));
  }

  void _show(String msg) {
    if (!mounted) return;
    final id = ++_toastId;
    setState(() => _toast = msg);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted && _toastId == id) setState(() => _toast = null);
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _flush?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: math.pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.06,
            numberOfParticles: 26,
            maxBlastForce: 22,
            minBlastForce: 8,
            gravity: 0.25,
            colors: const [N.goldHi, N.gold, N.goldLo, N.water, N.good, Colors.white],
          ),
        ),
        if (_toast != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 150 + bottom,
            child: IgnorePointer(
              child: Center(
                key: ValueKey(_toastId),
                child:
                    Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: N.goldGradient,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [
                              BoxShadow(color: Color(0x8C000000), blurRadius: 30, offset: Offset(0, 12)),
                            ],
                          ),
                          child: Text(
                            _toast!,
                            style: const TextStyle(
                              color: N.goldInk,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              fontFamily: N.body,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 160.ms)
                        .slideY(begin: .4, end: 0, duration: 220.ms, curve: Curves.easeOutBack)
                        .scaleXY(begin: .9, end: 1, duration: 220.ms),
              ),
            ),
          ),
      ],
    );
  }
}
