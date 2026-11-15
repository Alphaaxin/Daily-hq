/// Counts quick taps on empty space; fires once [target] taps land with no
/// more than [gap] between consecutive taps. Pure logic, so it's testable.
class TapCounter {
  TapCounter({this.target = 4, this.gap = const Duration(milliseconds: 450), this.maxMove = 24});

  int target;
  final Duration gap;

  /// Max pixels a finger may move between down and up and still be a tap,
  /// and max distance between taps in one burst.
  final double maxMove;

  int _count = 0;
  DateTime? _last;
  (double, double)? _lastPos;

  /// Records a completed tap. Returns true when this tap completes the burst.
  bool tap(DateTime at, double x, double y, {double moved = 0}) {
    if (moved > maxMove) {
      reset();
      return false;
    }
    final near =
        _lastPos == null || ((_lastPos!.$1 - x).abs() <= maxMove * 4 && (_lastPos!.$2 - y).abs() <= maxMove * 4);
    if (_last == null || at.difference(_last!) > gap || !near) {
      _count = 0;
    }
    _count++;
    _last = at;
    _lastPos = (x, y);
    if (_count >= target) {
      reset();
      return true;
    }
    return false;
  }

  void reset() {
    _count = 0;
    _last = null;
    _lastPos = null;
  }
}
