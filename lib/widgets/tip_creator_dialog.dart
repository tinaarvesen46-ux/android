import 'package:flutter/material.dart';
import '../api/services/lens_service.dart';

/// TipCreatorDialog — small modal for sending a real tip on a lens.  Presets
/// $2 / $5 / $10 / custom, optional message.  Only ever shown when the lens
/// is `moderation_status = approved` and the current user isn't the creator.
class TipCreatorDialog extends StatefulWidget {
  const TipCreatorDialog({super.key, required this.lens});
  final Map<String, dynamic> lens;

  static Future<Map<String, dynamic>?> show(BuildContext context, Map<String, dynamic> lens) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TipCreatorDialog(lens: lens),
    );
  }

  @override
  State<TipCreatorDialog> createState() => _TipCreatorDialogState();
}

class _TipCreatorDialogState extends State<TipCreatorDialog> {
  double _amount = 5;
  final _msg = TextEditingController();
  final _custom = TextEditingController();
  bool _sending = false;
  String? _err;

  Future<void> _send() async {
    setState(() { _sending = true; _err = null; });
    final res = await LensService().tip(
      widget.lens['id'].toString(),
      amount: _amount,
      message: _msg.text.trim(),
    );
    if (!mounted) return;
    if (res == null || res['ok'] != true) {
      setState(() { _sending = false; _err = 'Tip failed.  Please try again.'; });
      return;
    }
    Navigator.of(context).pop(res);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = (widget.lens['name'] ?? 'this lens').toString();
    return AlertDialog(
      title: Row(children: [
        const Icon(Icons.volunteer_activism, color: Colors.pinkAccent),
        const SizedBox(width: 8),
        Expanded(child: Text('Tip creator', maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Send a tip to the creator of "$name".  10% platform fee applies; the rest lands in their available balance.',
              style: TextStyle(fontSize: 12, color: theme.hintColor)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            for (final v in const [2.0, 5.0, 10.0, 20.0])
              ChoiceChip(
                key: Key('tip-preset-$v'),
                label: Text('\$${v.toStringAsFixed(0)}'),
                selected: _amount == v,
                onSelected: (_) => setState(() { _amount = v; _custom.clear(); }),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(
            key: const Key('tip-custom'),
            controller: _custom,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null && parsed >= 1 && parsed <= 500) setState(() => _amount = parsed);
            },
            decoration: const InputDecoration(labelText: 'Custom amount (\$1–\$500)', prefixText: '\$'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('tip-message'),
            controller: _msg,
            maxLength: 280,
            decoration: const InputDecoration(labelText: 'Optional message', hintText: 'Nice work! Loved this lens.'),
          ),
          if (_err != null) Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_err!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ]),
      ),
      actions: [
        TextButton(key: const Key('tip-cancel'), onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton.icon(
          key: const Key('tip-send'),
          onPressed: _sending ? null : _send,
          icon: _sending
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send, size: 16),
          label: Text('Send \$${_amount.toStringAsFixed(2)}'),
        ),
      ],
    );
  }
}
