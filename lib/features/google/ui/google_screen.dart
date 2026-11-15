import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/dialogs.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/time/format.dart';
import '../data/drive_backup.dart';
import '../data/google_auth.dart';
import '../data/google_jobs.dart';

final _backupsProvider = FutureProvider.autoDispose<List<BackupInfo>>((ref) async {
  if (ref.watch(settingsProvider).googleEmail.isEmpty) return const [];
  return ref.read(driveBackupProvider).list();
});

class GoogleScreen extends ConsumerStatefulWidget {
  const GoogleScreen({super.key});

  @override
  ConsumerState<GoogleScreen> createState() => _GoogleScreenState();
}

class _GoogleScreenState extends ConsumerState<GoogleScreen> {
  String? _busy;

  Future<void> _run(String label, Future<String?> Function() job) async {
    setState(() => _busy = label);
    try {
      final msg = await job();
      if (mounted && msg != null) showSnack(context, msg);
    } catch (e) {
      if (mounted) showSnack(context, '$label failed: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final signedIn = s.googleEmail.isNotEmpty;
    final last = DateTime.tryParse(s.lastBackupUtc);
    final clock = ref.watch(clockProvider);
    final backups = ref.watch(_backupsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Google account & backup', style: N.h2.copyWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          GlassCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(gradient: N.goldGradient, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.cloud_done_outlined, color: N.goldInk),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(signedIn ? s.googleEmail : 'Not connected', style: N.h2),
                          Text(
                            signedIn ? 'Calendar sync and Drive backup are on' : 'Everything still works offline',
                            style: N.small.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!signedIn) ...[
                  _setupRow(
                    'Web client ID',
                    s.googleWebClientId.isEmpty
                        ? 'Paste from Google Cloud'
                        : '${s.googleWebClientId.substring(0, s.googleWebClientId.length.clamp(0, 12))}…',
                    () async {
                      final clip = (await Clipboard.getData('text/plain'))?.text ?? '';
                      if (!context.mounted) return;
                      final v = await askText(
                        context,
                        'Web client ID (ends in .apps.googleusercontent.com)',
                        clip.contains('googleusercontent') ? clip.trim() : s.googleWebClientId,
                      );
                      if (v != null) await ref.read(settingsRepoProvider).set('googleWebClientId', v.trim());
                    },
                  ),
                  const SizedBox(height: 12),
                  NButton(
                    _busy == 'Sign in' ? 'Connecting…' : 'Sign in with Google',
                    icon: Icons.login_rounded,
                    expand: true,
                    onTap: _busy != null || s.googleWebClientId.isEmpty
                        ? null
                        : () => _run('Sign in', () async {
                            final email = await ref.read(googleAuthProvider).signIn();
                            await ref.read(googleJobsProvider).syncNow();
                            return 'Connected as $email';
                          }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The README walks you through creating the Google Cloud project and client IDs (about 10 minutes, once).',
                    style: N.small.copyWith(fontSize: 12),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: NButton(
                          _busy == 'Sync' ? 'Syncing…' : 'Sync calendar',
                          kind: BtnKind.raise,
                          icon: Icons.sync_rounded,
                          onTap: _busy != null
                              ? null
                              : () => _run('Sync', () async {
                                  final r = await ref.read(googleJobsProvider).syncNow();
                                  if (!r.ok) throw Exception(r.error);
                                  return 'Synced: ${r.pushed} sent, ${r.pulled} received';
                                }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NButton('Sign out', kind: BtnKind.ghost, onTap: () => ref.read(googleAuthProvider).signOut()),
                    ],
                  ),
              ],
            ),
          ),
          if (signedIn) ...[
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardHeader(
                    'Drive backup',
                    trailing: Text(
                      last == null ? 'never' : '${fmtDayKey(clock.calendarDateFor(last))}, ${fmtTime(clock, last)}',
                      style: N.small.copyWith(fontSize: 12),
                    ),
                  ),
                  Text(
                    'Your whole database, gzipped, in Drive\'s hidden app folder. The newest 14 are kept. '
                    'Runs after Good Night and at 10 AM as a safety net.',
                    style: N.small,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Text('Back up after Good Night', style: TextStyle(fontSize: 15))),
                      Switch(
                        value: s.backupAfterGoodNight,
                        onChanged: (v) => ref.read(settingsRepoProvider).set('backupAfterGoodNight', v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  NButton(
                    _busy == 'Backup' ? 'Backing up…' : 'Back up now',
                    icon: Icons.backup_outlined,
                    expand: true,
                    onTap: _busy != null
                        ? null
                        : () => _run('Backup', () async {
                            await ref.read(driveBackupProvider).backupNow();
                            ref.invalidate(_backupsProvider);
                            return 'Backed up to Google Drive ✓';
                          }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: N.gap),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader('Restore'),
                  backups.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator(color: N.gold, strokeWidth: 2)),
                    ),
                    error: (e, _) => EmptyNote('Couldn\'t list backups: $e'),
                    data: (l) => l.isEmpty
                        ? const EmptyNote('No backups yet.')
                        : Column(
                            children: [
                              for (final b in l)
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(top: BorderSide(color: N.line)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${fmtDayKey(clock.calendarDateFor(b.at))}, ${fmtTime(clock, b.at)}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Text('${(b.bytes / 1024).round()} KB', style: N.num(12, color: N.muted)),
                                      TextButton(
                                        onPressed: _busy != null ? null : () => _restore(b),
                                        child: const Text(
                                          'Restore',
                                          style: TextStyle(color: N.gold, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _restore(BackupInfo b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restore this backup?', style: N.h2),
        content: Text(
          'Everything on this phone is replaced with the backup from '
          '${fmtDayKey(ref.read(clockProvider).calendarDateFor(b.at))}. Solo Leveling will close; open it again.',
          style: N.small,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: N.muted)),
          ),
          NButton('Restore', kind: BtnKind.danger, onTap: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    await _run('Restore', () async {
      await ref.read(driveBackupProvider).restore(b);
      await SystemNavigator.pop();
      return null;
    });
  }

  Widget _setupRow(String title, String value, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          Text(
            value,
            style: const TextStyle(color: N.gold, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
