import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/background/background.dart';
import '../../../core/providers.dart';
import 'calendar_sync.dart';
import 'drive_backup.dart';

/// Foreground triggers for Google work: debounced calendar sync after task
/// edits and on resume, and the backup right after Good Night.
class GoogleJobs {
  GoogleJobs(this.ref);
  final Ref ref;
  Timer? _t;
  DateTime? _lastSync;

  bool get _signedIn => ref.read(settingsProvider).googleEmail.isNotEmpty;

  void syncSoon({Duration delay = const Duration(seconds: 5)}) {
    if (!_signedIn) return;
    _t?.cancel();
    _t = Timer(delay, () => unawaited(syncNow()));
  }

  /// On app open / resume, at most every 10 minutes.
  void syncOnResume() {
    if (_lastSync != null && DateTime.now().difference(_lastSync!) < const Duration(minutes: 10)) return;
    syncSoon(delay: const Duration(seconds: 2));
  }

  Future<SyncResult> syncNow() async {
    if (!_signedIn) return const SyncResult(error: 'Not signed in to Google');
    _lastSync = DateTime.now();
    return ref.read(calendarSyncProvider).sync();
  }

  /// Right after Good Night: back up while you're still on Wi-Fi.
  Future<void> backupAfterGoodNight() async {
    final s = ref.read(settingsProvider);
    if (!_signedIn || !s.backupAfterGoodNight) return;
    try {
      await ref.read(driveBackupProvider).backupNow();
    } catch (_) {
      await queueBackupRetry();
    }
  }
}

final googleJobsProvider = Provider((ref) => GoogleJobs(ref));
