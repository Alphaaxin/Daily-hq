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

  /// What the app was opened with (widget route / shared text), once.
  static Future<Map<String, Object?>?> takeLaunch() async {
    try {
      final m = await _ch.invokeMapMethod<String, Object?>('takeLaunch');
      return m == null || (m['route'] == null && m['text'] == null) ? null : m;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateWidgets(Map<String, String> values) => _bool('updateWidgets', values);

  static Future<bool> hasUsageAccess() => _bool('hasUsageAccess');
  static Future<bool> requestUsageAccess() => _bool('requestUsageAccess');

  /// (package, label, minutes) for apps used since [fromUtc].
  static Future<List<(String, String, int)>> usageSince(DateTime fromUtc) async {
    try {
      final l = await _ch.invokeListMethod<Object?>('usageSince', fromUtc.millisecondsSinceEpoch) ?? const [];
      return [
        for (final e in l.whereType<Map>())
          ('${e['package']}', '${e['label']}', ((e['ms'] as num?) ?? 0) ~/ 60000),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Closes the Quick Log popup activity (no-op in the main app).
  static Future<bool> finishPopup() => _bool('finishPopup');
}
