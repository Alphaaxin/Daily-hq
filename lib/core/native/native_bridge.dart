import 'package:flutter/services.dart';

/// Calls into Nizam's own Kotlin code (MainActivity / QuickLogActivity):
/// floating bubble, overlay permission and Do Not Disturb.
/// Every call fails soft (returns false) so tests and older phones are fine.
class NativeBridge {
  NativeBridge._();
  static const _ch = MethodChannel('nizam/native');

  static Future<bool> _bool(String m, [Object? args]) async {
    try {
      return await _ch.invokeMethod<bool>(m, args) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canDrawOverlays() => _bool('canDrawOverlays');
  static Future<bool> requestOverlay() => _bool('requestOverlay');
  static Future<bool> startBubble() => _bool('startBubble');
  static Future<bool> stopBubble() => _bool('stopBubble');

  static Future<bool> hasDndAccess() => _bool('hasDndAccess');
  static Future<bool> requestDndAccess() => _bool('requestDndAccess');

  /// true = priority-only (silence), false = back to normal.
  static Future<bool> setDnd(bool on) => _bool('setDnd', on);

  /// Closes the Quick Log popup activity (no-op in the main app).
  static Future<bool> finishPopup() => _bool('finishPopup');
}
