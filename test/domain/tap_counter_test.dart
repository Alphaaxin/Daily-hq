import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/money/domain/tap_counter.dart';

void main() {
  final t0 = DateTime(2026, 11, 15, 12);
  DateTime ms(int m) => t0.add(Duration(milliseconds: m));

  test('four quick taps fire once', () {
    final c = TapCounter();
    expect(c.tap(ms(0), 100, 100), isFalse);
    expect(c.tap(ms(200), 102, 101), isFalse);
    expect(c.tap(ms(400), 99, 103), isFalse);
    expect(c.tap(ms(600), 100, 100), isTrue);
    // the burst resets after firing
    expect(c.tap(ms(800), 100, 100), isFalse);
  });

  test('a slow tap restarts the count', () {
    final c = TapCounter();
    c.tap(ms(0), 0, 0);
    c.tap(ms(200), 0, 0);
    c.tap(ms(1000), 0, 0); // gap > 450ms → count restarts at 1
    expect(c.tap(ms(1200), 0, 0), isFalse);
    expect(c.tap(ms(1400), 0, 0), isFalse);
    expect(c.tap(ms(1600), 0, 0), isTrue);
  });

  test('a drag or a far-away tap breaks the burst', () {
    final c = TapCounter();
    c.tap(ms(0), 0, 0);
    c.tap(ms(150), 0, 0);
    expect(c.tap(ms(300), 0, 0, moved: 60), isFalse); // that was a scroll
    expect(c.tap(ms(450), 0, 0), isFalse);
    expect(c.tap(ms(600), 500, 500), isFalse); // other side of the screen
  });

  test('configurable count', () {
    final c = TapCounter(target: 3);
    c.tap(ms(0), 0, 0);
    c.tap(ms(100), 0, 0);
    expect(c.tap(ms(200), 0, 0), isTrue);
  });

  test('two double-taps on buttons never add up to four', () {
    // Taps inside cards call reset(), modelled here.
    final c = TapCounter();
    c.tap(ms(0), 0, 0);
    c.tap(ms(100), 0, 0);
    c.reset();
    c.tap(ms(200), 0, 0);
    expect(c.tap(ms(300), 0, 0), isFalse);
  });
}
