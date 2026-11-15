import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../core/theme/widgets.dart';
import '../domain/tap_counter.dart';

/// Wraps a screen and calls [onTrigger] after [taps] quick taps on empty
/// space (anywhere not inside a [NoQuickTap] area). It never consumes taps,
/// so normal scrolling and buttons keep working.
class EmptyTapZone extends StatefulWidget {
  const EmptyTapZone({super.key, required this.child, required this.onTrigger, this.taps = 4, this.enabled = true});
  final Widget child;
  final VoidCallback onTrigger;
  final int taps;
  final bool enabled;

  @override
  State<EmptyTapZone> createState() => _EmptyTapZoneState();
}

class _EmptyTapZoneState extends State<EmptyTapZone> {
  final _counter = TapCounter();
  final _downs = <int, (Offset, DateTime)>{};

  bool _isEmptySpace(Offset global) {
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, global, View.of(context).viewId);
    for (final e in result.path) {
      final t = e.target;
      if (t is RenderMetaData && t.metaData == kNoQuickTap) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    _counter.target = widget.taps.clamp(2, 8);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (_isEmptySpace(e.position)) {
          _downs[e.pointer] = (e.position, DateTime.now());
        } else {
          _counter.reset();
        }
      },
      onPointerUp: (e) {
        final d = _downs.remove(e.pointer);
        if (d == null) return;
        final held = DateTime.now().difference(d.$2);
        if (held > const Duration(milliseconds: 350)) {
          _counter.reset();
          return;
        }
        if (_counter.tap(DateTime.now(), e.position.dx, e.position.dy, moved: (e.position - d.$1).distance)) {
          widget.onTrigger();
        }
      },
      onPointerCancel: (e) => _downs.remove(e.pointer),
      child: widget.child,
    );
  }
}
