import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class MessageComposer extends StatefulWidget {
  final ValueChanged<String> onSend;
  final ValueChanged<bool>? onTypingChanged;
  final bool enabled;
  final String hintText;

  const MessageComposer({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.enabled = true,
    this.hintText = 'Send a message',
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;
  bool _isTyping = false;
  Timer? _typingStopTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
      _handleTyping(canSend);
    });
  }

  void _handleTyping(bool hasText) {
    if (hasText) {
      if (!_isTyping) {
        _isTyping = true;
        widget.onTypingChanged?.call(true);
      }
      _typingStopTimer?.cancel();
      _typingStopTimer = Timer(const Duration(seconds: 3), () {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      });
    } else if (_isTyping) {
      _isTyping = false;
      _typingStopTimer?.cancel();
      widget.onTypingChanged?.call(false);
    }
  }

  @override
  void dispose() {
    _typingStopTimer?.cancel();
    if (_isTyping) widget.onTypingChanged?.call(false);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _typingStopTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        top: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm + safeBottom + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AppTheme.borderThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: theme.textTheme.bodyMedium,
              enabled: widget.enabled,
              decoration: InputDecoration(hintText: widget.hintText),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Semantics(
            button: true,
            label: 'Send message',
            child: GestureDetector(
              onTap: widget.enabled && _canSend ? _submit : null,
              child: Container(
                width: AppTheme.buttonHeight,
                height: AppTheme.buttonHeight,
                decoration: BoxDecoration(
                  color: _canSend
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: AppTheme.iconSm,
                  color: _canSend
                      ? theme.colorScheme.onPrimary
                      : appColors.subtleText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
