import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';
import '../../profiles/data/profiles_repo.dart';
import '../data/money_repo.dart';
import '../domain/money_parser.dart';

/// Opens Quick Log as a bottom sheet inside the app.
Future<void> showQuickLog(BuildContext context) => showNSheet(context, (_) => const QuickLogForm());

/// The Quick Log form. Used in a sheet and by the Quick Settings tile popup.
class QuickLogForm extends ConsumerStatefulWidget {
  const QuickLogForm({super.key, this.onDone});

  /// Called after saving or cancelling; defaults to popping the route.
  final void Function(bool saved)? onDone;

  @override
  ConsumerState<QuickLogForm> createState() => _QuickLogFormState();
}

class _QuickLogFormState extends ConsumerState<QuickLogForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _noteFocus = FocusNode();
  MoneyType _type = MoneyType.spent;
  int? _cat;
  int? _profile;
  bool _typeTouched = false, _catTouched = false, _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  List<Category> _cats() =>
      (ref.read(categoriesProvider).value ?? const <Category>[]).where((c) => c.type == _type.name).toList();

  /// Re-reads both fields and fills type / category unless you've picked them.
  void _smart() {
    final pa = parseMoney(_amount.text), pn = parseMoney(_note.text);
    final type = pn.type ?? pa.type;
    final cat = pn.category ?? pa.category;
    setState(() {
      if (type != null && !_typeTouched) _type = type;
      final cats = _cats();
      if (cat != null && !_catTouched) {
        final match = cats.where((c) => c.name.toLowerCase() == cat.toLowerCase()).firstOrNull;
        if (match != null) _cat = match.id;
      }
      if (_cat == null || !cats.any((c) => c.id == _cat)) _cat = cats.firstOrNull?.id;
    });
  }

  void _close(bool saved) {
    if (widget.onDone != null) {
      widget.onDone!(saved);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    var paise = parseMoney(_amount.text).paise;
    final fromNote = parseMoney(_note.text);
    paise ??= fromNote.paise;
    if (paise == null || paise <= 0) {
      Haptic.tap();
      showSnack(context, 'Enter an amount');
      return;
    }
    final cats = _cats();
    final catId = _cat ?? cats.firstOrNull?.id;
    if (catId == null) return;
    // If the amount was typed into the note ("250 chai"), keep only the words.
    final note = _amount.text.trim().isEmpty ? fromNote.note : _note.text.trim();
    setState(() => _saving = true);
    final s = ref.read(settingsProvider);
    final alerts = await ref
        .read(moneyRepoProvider)
        .add(
          paise: paise,
          type: _type,
          categoryId: catId,
          note: note,
          profileId: _profile,
          clock: ref.read(clockProvider),
          monthlyBudgetPaise: s.monthlyBudgetPaise > 0 ? s.monthlyBudgetPaise : null,
        );
    Haptic.light();
    for (final a in alerts) {
      await NotificationService.instance.showNow(
        a.level == BudgetLevel.over ? 4101 : 4100,
        a.level == BudgetLevel.over ? 'Over budget' : 'Budget check',
        a.message,
        payload: 'money',
      );
    }
    if (!mounted) return;
    final msg = '${_type.label} ${formatInr(paise)}${alerts.isEmpty ? '' : ' · ${alerts.first.message}'}';
    final messenger = ScaffoldMessenger.maybeOf(context);
    _close(true);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: N.ink)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(categoriesProvider).value ?? const <Category>[];
    final cats = all.where((c) => c.type == _type.name).toList();
    final cat = _cat != null && cats.any((c) => c.id == _cat) ? _cat : cats.firstOrNull?.id;
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final typeColor = switch (_type) {
      MoneyType.spent => N.bad,
      MoneyType.invested => N.water,
      MoneyType.received => N.good,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text('Log money', style: N.h2.copyWith(fontSize: 18))),
            IconButton(
              tooltip: 'Close',
              onPressed: () => _close(false),
              icon: const Icon(Icons.close_rounded, color: N.muted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+]'))],
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          style: N.num(34, color: typeColor, weight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '₹0',
            hintStyle: N.num(34, color: N.muted.withValues(alpha: .5)),
            prefixText: _amount.text.isEmpty ? null : '₹ ',
            prefixStyle: N.num(26, color: typeColor),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (_) => _smart(),
          onSubmitted: (_) => _note.text.trim().isEmpty ? _noteFocus.requestFocus() : _save(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _note,
          focusNode: _noteFocus,
          maxLength: 120,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: 'What for? chai, SIP, +retainer…', counterText: ''),
          onChanged: (_) => _smart(),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final t in MoneyType.values) ...[
              if (t.index > 0) const SizedBox(width: 6),
              Expanded(
                child: _TypeButton(
                  label: t.label,
                  on: _type == t,
                  color: switch (t) {
                    MoneyType.spent => N.bad,
                    MoneyType.invested => N.water,
                    MoneyType.received => N.good,
                  },
                  onTap: () => setState(() {
                    _type = t;
                    _typeTouched = true;
                    final c = _cats();
                    if (!c.any((x) => x.id == _cat)) _cat = c.firstOrNull?.id;
                  }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in cats)
              NChip(
                c.name,
                on: cat == c.id,
                color: typeColor,
                onTap: () => setState(() {
                  _cat = c.id;
                  _catTouched = true;
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              NChip('No profile', on: _profile == null, onTap: () => setState(() => _profile = null)),
              for (final p in profiles) ...[
                const SizedBox(width: 6),
                NChip(
                  p.name,
                  on: _profile == p.id,
                  color: Color(p.color),
                  onTap: () => setState(() => _profile = p.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        NButton(_saving ? 'Saving…' : 'Save', expand: true, onTap: _saving ? null : _save),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({required this.label, required this.on, required this.color, required this.onTap});
  final String label;
  final bool on;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: on ? color.withValues(alpha: .13) : N.raise,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: on ? color : N.line),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Haptic.tap();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: on ? color : N.muted),
          ),
        ),
      ),
    ),
  );
}
