import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/native/native_bridge.dart';
import '../core/theme/nizam_theme.dart';
import '../core/theme/tokens.dart';
import '../features/money/ui/quick_log_sheet.dart';

/// The whole app when launched by the Quick Settings tile, widget or bubble:
/// a dimmed screen with just the Quick Log card at the bottom.
class QuickLogPopupApp extends StatelessWidget {
  const QuickLogPopupApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: nizamTheme(),
    color: Colors.transparent,
    home: const _Popup(),
  );
}

class _Popup extends ConsumerStatefulWidget {
  const _Popup();

  @override
  ConsumerState<_Popup> createState() => _PopupState();
}

class _PopupState extends ConsumerState<_Popup> {
  bool _saved = false;

  Future<void> _close(bool saved) async {
    if (saved) {
      HapticFeedback.mediumImpact();
      setState(() => _saved = true);
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }
    if (!await NativeBridge.finishPopup()) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black54,
    resizeToAvoidBottomInset: true,
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _close(false),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // taps inside the card don't close it
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: N.solid,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x38D9B46A)),
                boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 16))],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _saved
                    ? const SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: N.gold, size: 42),
                              SizedBox(height: 8),
                              Text('Logged · +5 XP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(child: QuickLogForm(onDone: _close)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
