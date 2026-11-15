import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';

const _pkg = 'com.habeeb.nizam';

/// Step-by-step walkthrough so Vivo / OriginOS never kills reminders.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, this.firstRun = false});
  final bool firstRun;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> with WidgetsBindingObserver {
  bool _notif = false, _exact = false, _battery = false, _overlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final n = NotificationService.instance;
    final r = await Future.wait(
      [
        n.notificationsAllowed(),
        n.exactAllowed(),
        Permission.ignoreBatteryOptimizations.isGranted,
        Permission.systemAlertWindow.isGranted,
      ].map((f) => f.catchError((_) => false)),
    );
    if (!mounted) return;
    setState(() {
      _notif = r[0];
      _exact = r[1];
      _battery = r[2];
      _overlay = r[3];
    });
  }

  Future<void> _openAutostart() async {
    // Vivo / iQOO keep these screens in different places across OriginOS / Funtouch versions.
    const candidates = [
      ('com.vivo.permissionmanager', 'com.vivo.permissionmanager.activity.BgStartUpManagerActivity'),
      ('com.iqoo.secure', 'com.iqoo.secure.ui.phoneoptimize.BgStartUpManager'),
      ('com.iqoo.secure', 'com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity'),
      ('com.vivo.permissionmanager', 'com.vivo.permissionmanager.activity.PurviewTabActivity'),
    ];
    for (final (pkg, cls) in candidates) {
      try {
        await AndroidIntent(componentName: cls, package: pkg).launch();
        return;
      } catch (_) {}
    }
    await _appDetails();
  }

  Future<void> _appDetails() async {
    try {
      await const AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:$_pkg',
      ).launch();
    } catch (_) {
      await openAppSettings();
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsRepoProvider).set('onboarded', true);
    ref.read(reminderSyncProvider).schedule();
    if (mounted) context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final steps = [
      _Step(
        n: 1,
        title: 'Allow notifications',
        body: 'Water, task and bedtime reminders.',
        done: _notif,
        action: 'Allow',
        onTap: () async {
          await NotificationService.instance.requestNotifications();
          _refresh();
        },
      ),
      _Step(
        n: 2,
        title: 'Allow exact alarms',
        body: 'So reminders fire on the minute, not "sometime later".',
        done: _exact,
        action: 'Allow',
        onTap: () async {
          await NotificationService.instance.requestExact();
          _refresh();
        },
      ),
      _Step(
        n: 3,
        title: 'Turn off battery optimisation',
        body:
            'Choose "Don\'t optimise" / "Allow" for Solo Leveling. On OriginOS also check Settings → Battery → '
            'Background power consumption management → Solo Leveling → Allow background high power consumption.',
        done: _battery,
        action: 'Open',
        onTap: () async {
          await Permission.ignoreBatteryOptimizations.request();
          _refresh();
        },
      ),
      _Step(
        n: 4,
        title: 'Allow Autostart',
        body:
            'i Manager → App manager → Autostart → switch on Solo Leveling. If the screen doesn\'t open, go to '
            'Settings → Apps → Autostart. Vivo also offers "Lock" in recent apps: pull Solo Leveling down to lock it.',
        done: s.autostartConfirmed,
        action: 'Open',
        onTap: _openAutostart,
        confirm: s.autostartConfirmed ? null : () => ref.read(settingsRepoProvider).set('autostartConfirmed', true),
      ),
      _Step(
        n: 5,
        title: 'Display over other apps',
        body: 'Needed later for the ₹ quick-log popup and floating bubble.',
        done: _overlay,
        action: 'Allow',
        onTap: () async {
          await Permission.systemAlertWindow.request();
          _refresh();
        },
      ),
    ];
    final allDone = _notif && _exact && _battery && _overlay && s.autostartConfirmed;

    return Scaffold(
      appBar: widget.firstRun
          ? null
          : AppBar(
              backgroundColor: N.bg,
              surfaceTintColor: Colors.transparent,
              title: Text('Phone setup', style: N.h2),
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (widget.firstRun) ...[
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(gradient: N.goldGradient, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 10),
                  Text('SOLO LEVELING', style: N.h2.copyWith(letterSpacing: 4)),
                ],
              ),
              const SizedBox(height: 22),
              Text('Salaam, ${s.name}.', style: N.h1),
              const GoldText(
                'Let\'s make reminders unkillable.',
                style: TextStyle(fontFamily: N.display, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Vivo\'s battery manager stops background apps. Five quick switches and Solo Leveling will always reach you.',
                style: N.small.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
            for (final st in steps) ...[st, const SizedBox(height: 10)],
            const SizedBox(height: 10),
            NButton(
              allDone ? 'All set: open Solo Leveling' : (widget.firstRun ? 'Continue' : 'Done'),
              expand: true,
              onTap: _finish,
            ),
            if (!allDone) ...[
              const SizedBox(height: 8),
              Text('You can finish this later from Me → Phone setup.', textAlign: TextAlign.center, style: N.small),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.title,
    required this.body,
    required this.done,
    required this.action,
    required this.onTap,
    this.confirm,
  });
  final int n;
  final String title;
  final String body;
  final bool done;
  final String action;
  final VoidCallback onTap;
  final VoidCallback? confirm;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: done ? N.goldGradient : null,
            border: done ? null : Border.all(color: N.line, width: 1.5),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 18, color: N.goldInk)
              : Text('$n', style: N.num(13, color: N.muted)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: N.h2),
              const SizedBox(height: 4),
              Text(body, style: N.small),
              if (!done) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NButton(action, onTap: onTap),
                    if (confirm != null) NButton('I did it', kind: BtnKind.raise, onTap: confirm),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
