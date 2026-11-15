import 'package:flutter/material.dart';

import 'tokens.dart';
import 'widgets.dart';

Future<String?> askText(BuildContext context, String title, String initial) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: N.h2),
      content: TextField(controller: c, autofocus: true, onSubmitted: (v) => Navigator.pop(ctx, v)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: N.muted)),
        ),
        NButton('Save', onTap: () => Navigator.pop(ctx, c.text)),
      ],
    ),
  );
}

Future<int?> askInt(BuildContext context, String title, int initial, int min, int max, {String Function(int)? fmt}) {
  var v = initial.clamp(min, max);
  return showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title, style: N.h2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconBtn(Icons.remove_rounded, onTap: () => setState(() => v = (v - 1).clamp(min, max))),
            SizedBox(
              width: 120,
              child: Text(fmt?.call(v) ?? '$v', textAlign: TextAlign.center, style: N.num(22)),
            ),
            IconBtn(Icons.add_rounded, onTap: () => setState(() => v = (v + 1).clamp(min, max))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: N.muted)),
          ),
          NButton('Save', onTap: () => Navigator.pop(ctx, v)),
        ],
      ),
    ),
  );
}
