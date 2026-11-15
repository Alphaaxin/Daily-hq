import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';
import '../core/theme/widgets.dart';
import '../core/providers.dart';
import '../core/settings/app_settings.dart';
import '../features/money/ui/empty_tap_zone.dart';
import '../features/money/ui/quick_log_sheet.dart';
import '../features/quick_capture/ui/quick_capture_sheet.dart';

const _tabs = [
  ('Today', Icons.wb_sunny_outlined, Icons.wb_sunny_rounded),
  ('Money', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded),
  ('Notes', Icons.sticky_note_2_outlined, Icons.sticky_note_2_rounded),
  ('Rewards', Icons.star_outline_rounded, Icons.star_rounded),
  ('Me', Icons.person_outline_rounded, Icons.person_rounded),
];

/// Glass top bar, tab content, glass bottom nav and the gold ₹ button.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = MediaQuery.of(context).padding;
    final s = ref.watch(settingsProvider);
    final money = s.on(Module.money);
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -1.1),
            radius: 1.3,
            colors: [Color(0x21D9B46A), Color(0x00000000)],
          ),
        ),
        child: Column(
          children: [
            _TopBar(top: pad.top),
            Expanded(
              child: EmptyTapZone(
                enabled: money,
                taps: s.quickLogTaps,
                onTrigger: () => showQuickLog(context),
                child: shell,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _GoldFab(
          onTap: () => money ? showQuickLog(context) : showQuickCapture(context),
          onLongPress: () => showQuickCapture(context),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: shell.currentIndex,
        onTap: (i) {
          Haptic.tap();
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.top});
  final double top;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
        decoration: const BoxDecoration(
          color: Color(0xC707080B),
          border: Border(bottom: BorderSide(color: N.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: N.goldGradient,
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [BoxShadow(color: Color(0x59D9B46A), blurRadius: 18)],
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: GoldText(
                  'SOLO LEVELING',
                  style: TextStyle(fontFamily: N.display, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2.2),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Row(
              children: [
                SizedBox(
                  width: 7,
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: N.good, shape: BoxShape.circle),
                  ),
                ),
                SizedBox(width: 6),
                Text('On this phone', style: TextStyle(fontSize: 12, color: N.muted)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _GoldFab extends StatelessWidget {
  const _GoldFab({required this.onTap, required this.onLongPress});
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Log money. Long-press for quick capture',
    child: GestureDetector(
      onTap: () {
        Haptic.light();
        onTap();
      },
      onLongPress: () {
        Haptic.win();
        onLongPress();
      },
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: N.goldGradient,
          border: Border.all(color: const Color(0x40FFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x59D9B46A), blurRadius: 30, offset: Offset(0, 10)),
            BoxShadow(color: Color(0x8C000000), blurRadius: 40, offset: Offset(0, 16)),
          ],
        ),
        child: const Text(
          '₹',
          style: TextStyle(fontFamily: N.display, fontSize: 26, fontWeight: FontWeight.w700, color: N.goldInk),
        ),
      ),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xD10A0B0F),
          border: Border(top: BorderSide(color: N.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: i == index,
                      button: true,
                      label: _tabs[i].$1,
                      child: InkWell(
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == index ? _tabs[i].$3 : _tabs[i].$2,
                              size: 23,
                              color: i == index ? N.goldHi : N.muted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _tabs[i].$1,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: i == index ? N.goldHi : N.muted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: i == index ? 18 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: N.goldGradient,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: const [BoxShadow(color: Color(0x99D9B46A), blurRadius: 10)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
