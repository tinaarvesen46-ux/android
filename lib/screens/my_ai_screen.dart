import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_failure.dart';
import '../repositories/ai_repository.dart';
import '../theme/theme.dart';
import '../widgets/chats/message_composer.dart';
import '../widgets/common/app_top_bar.dart';

class MyAiScreen extends StatefulWidget {
  const MyAiScreen({super.key});

  @override
  State<MyAiScreen> createState() => _MyAiScreenState();
}

class _MyAiScreenState extends State<MyAiScreen> {
  final ScrollController _scroll = ScrollController();
  final List<_AiLine> _lines = [];
  bool _busy = false;
  bool _historyLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    try {
      final history = await context.read<AiRepository>().history();
      if (!mounted) return;
      setState(() {
        _lines
          ..clear()
          ..addAll(history.map((message) => _AiLine(
                text: message.content,
                fromUser: message.role == 'user',
              )));
        _historyLoading = false;
      });
    } on ApiFailure catch (e) {
      if (mounted) setState(() { _historyLoading = false; _error = e.message; });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _busy) return;
    setState(() {
      _lines.add(_AiLine(text: trimmed, fromUser: true));
      _busy = true;
      _error = null;
    });
    _scrollToEnd();
    try {
      final reply = await context.read<AiRepository>().sendMessage(trimmed);
      if (!mounted) return;
      setState(() => _lines.add(_AiLine(text: reply.text, fromUser: false)));
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: AppTheme.animNormal, curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Scaffold(
      body: Column(children: [
        AppTopBar(
          showBack: true,
          titleWidget: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: theme.colorScheme.primary, child: Icon(Icons.auto_awesome_rounded, size: 17, color: theme.colorScheme.onPrimary)),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('My AI'),
          ]),
          actions: [IconButton(tooltip: 'My AI settings', icon: const Icon(Icons.info_outline_rounded), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('My AI settings are in Settings > Generative AI.')))],
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            children: [
              if (_historyLoading)
                const Padding(
                  padding: EdgeInsets.only(top: AppTheme.spacingHuge),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_historyLoading && _lines.isEmpty) ...[
                const SizedBox(height: AppTheme.spacingHuge),
                Icon(Icons.auto_awesome_rounded, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppTheme.spacingMd),
                Text('Ask My AI', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingSm),
                Text('My AI answers through the SwiftSnap server when a provider is configured.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText)),
                const SizedBox(height: AppTheme.spacingXl),
                Wrap(spacing: AppTheme.spacingSm, runSpacing: AppTheme.spacingSm, alignment: WrapAlignment.center, children: ['Plan my day', 'Give me a caption', 'Explain something'].map((suggestion) => ActionChip(label: Text(suggestion), onPressed: _busy ? null : () => _send(suggestion))).toList()),
              ],
              ..._lines.map((line) => Align(
                    alignment: line.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(color: line.fromUser ? appColors.chatBubbleSelf : appColors.chatBubbleOther, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                      child: Text(line.text, style: theme.textTheme.bodyMedium?.copyWith(color: appColors.onMedia)),
                    ),
                  )),
              if (_busy) const Padding(padding: EdgeInsets.all(AppTheme.spacingSm), child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator())),
              if (_error != null) ...[
                Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                TextButton.icon(onPressed: _busy || _lines.isEmpty ? null : () => _send(_lines.lastWhere((line) => line.fromUser).text), icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
              ],
            ],
          ),
        ),
        MessageComposer(onSend: _send, enabled: !_busy, hintText: 'Ask My AI'),
      ]),
    );
  }
}

class _AiLine {
  final String text;
  final bool fromUser;

  const _AiLine({required this.text, required this.fromUser});
}
