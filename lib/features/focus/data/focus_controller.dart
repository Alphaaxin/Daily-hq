import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';
import '../domain/focus_logic.dart';
import 'focus_repo.dart';

/// Starts / pauses / stops focus sessions and keeps their side effects in
/// sync: the ongoing notification, Pomodoro alarm, 20-20-20 breaks and DND.
class FocusController {
  FocusController(this.ref);
  final Ref ref;
  final _n = NotificationService.instance;

  FocusRepo get _repo => ref.read(focusRepoProvider);

  Future<void> start(FocusKind kind, {int? profileId, int? ideaId, int? learningId}) async {
    final clock = ref.read(clockProvider);
    await _repo.start(clock, kind, profileId: profileId, ideaId: ideaId, learningId: learningId);
    await _sync();
    final s = ref.read(settingsProvider);
    if (kind == FocusKind.pomodoro && s.focusDnd && await NativeBridge.hasDndAccess()) {
      await NativeBridge.setDnd(true);
    }
  }

  Future<void> pause() async {
    final cur = await _repo.running();
    if (cur == null) return;
    await _repo.pause(ref.read(clockProvider), cur);
    await _sync();
  }

  Future<void> resume() async {
    final cur = await _repo.running();
    if (cur == null) return;
    await _repo.resume(ref.read(clockProvider), cur);
    await _sync();
  }

  Future<FocusSession?> stop({String? note, int? ideaId}) async {
    final cur = await _repo.running();
    if (cur == null) return null;
    final done = await _repo.stop(
      ref.read(clockProvider),
      cur,
      note: note,
      ideaId: ideaId,
      pomoMinutes: ref.read(settingsProvider).pomoWork,
    );
    await _n.cancelFocus();
    if (done.focusKind == FocusKind.pomodoro) await NativeBridge.setDnd(false);
    return done;
  }

  /// Re-draws notifications from the database (also called on app resume,
  /// so a timer survives Vivo killing the app).
  Future<void> _sync() async {
    final cur = await _repo.running();
    await _n.cancelFocus();
    if (cur == null) return;
    final s = ref.read(settingsProvider);
    final now = ref.read(clockProvider).nowUtc();
    final elapsed = cur.elapsed(now);
    await _n.showFocusOngoing(
      title: cur.focusKind.label,
      startMs: now.subtract(Duration(seconds: elapsed)).millisecondsSinceEpoch,
      paused: cur.paused,
    );
    if (cur.paused) return;
    if (cur.focusKind == FocusKind.pomodoro) {
      final left = s.pomoWork * 60 - elapsed;
      if (left > 0) {
        await _n.scheduleFocusDone(
          now.add(Duration(seconds: left)),
          'Pomodoro done 🍅',
          '+10 XP. Take a ${s.pomoBreak}-minute break: stand up, water, stretch.',
        );
      }
    } else if (cur.focusKind == FocusKind.build) {
      final int left = 3600 - ref.read(buildSecondsTodayProvider);
      if (left > 0) {
        await _n.scheduleFocusDone(
          now.add(Duration(seconds: left)),
          'Build Hour complete 🚀',
          'An hour of building today. Stop the timer and log what you shipped.',
        );
      }
    }
    if (s.eyeBreaks) {
      // Every 20 minutes of focus from here, for the next ~3 hours.
      final int next = 1200 - elapsed % 1200;
      await _n.scheduleEyeBreaks([for (var i = 0; i < 9; i++) now.add(Duration(seconds: next + i * 1200))]);
    }
  }

  Future<void> resync() => _sync();
}

final focusControllerProvider = Provider((ref) => FocusController(ref));
