import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_service.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/widgets.dart';

final _hasKeyProvider = FutureProvider.autoDispose<bool>((ref) => ref.read(aiProvider).hasKey);

/// Gemini key (Android secure storage) and model choice.
class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _key = TextEditingController();
  bool _busy = false;

  static const models = ['gemini-2.5-flash', 'gemini-2.5-pro', 'gemini-2.5-flash-lite'];

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = ref.watch(_hasKeyProvider).value ?? false;
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: N.bg,
        surfaceTintColor: Colors.transparent,
        title: Text('AI (Gemini)', style: N.h2.copyWith(fontSize: 18)),
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
                    Icon(hasKey ? Icons.verified_rounded : Icons.key_rounded, color: hasKey ? N.good : N.gold),
                    const SizedBox(width: 10),
                    Text(hasKey ? 'Key saved on this phone' : 'No key yet', style: N.h2),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Used for meeting minutes, voice notes, tidying notes, e-mail drafts and birthday wishes. '
                  'Get a free key at aistudio.google.com → Get API key. It\'s stored in Android\'s encrypted storage, '
                  'never in backups or the repo.',
                  style: N.small,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _key,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: hasKey ? 'Paste a new key to replace it' : 'Paste your Gemini API key',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NButton(
                        _busy ? 'Checking…' : 'Save & test',
                        onTap: _busy
                            ? null
                            : () async {
                                final ai = ref.read(aiProvider);
                                if (_key.text.trim().isNotEmpty) await ai.saveKey(_key.text);
                                setState(() => _busy = true);
                                try {
                                  final r = await ai.ping();
                                  if (context.mounted) showSnack(context, 'Gemini says: $r ✓');
                                  _key.clear();
                                } catch (e) {
                                  if (context.mounted) showSnack(context, '$e');
                                } finally {
                                  ref.invalidate(_hasKeyProvider);
                                  if (mounted) setState(() => _busy = false);
                                }
                              },
                      ),
                    ),
                    if (hasKey) ...[
                      const SizedBox(width: 8),
                      NButton(
                        'Remove',
                        kind: BtnKind.ghost,
                        onTap: () async {
                          await ref.read(aiProvider).clearKey();
                          ref.invalidate(_hasKeyProvider);
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: N.gap),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Model'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in {...models, s.geminiModel})
                      NChip(
                        m,
                        on: s.geminiModel == m,
                        onTap: () => ref.read(settingsRepoProvider).set('geminiModel', m),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Flash is fast and cheap; Pro is better for long or noisy meetings. You can type any model name '
                  'Google adds later in Me → Settings.',
                  style: N.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
