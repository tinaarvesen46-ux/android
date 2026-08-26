import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/report_service.dart';

/// Reusable report dialog wired to the real Laravel reports API.
/// - User reports  -> POST /reports/user   (reported_id, reason, description)
/// - Content reports-> POST /reports/content (content_type, content_id, reason, description)
///
/// `reason` values are constrained to the backend enum.
class ReportDialog extends StatefulWidget {
  /// When reporting a user directly, pass [userId].
  final String? userId;

  /// When reporting a piece of content, pass [contentType] (message|story|profile|comment)
  /// and [contentId].
  final String? contentType;
  final String? contentId;

  /// A short label of what is being reported, e.g. "@alex" or "this story".
  final String targetLabel;

  const ReportDialog.user({
    super.key,
    required String this.userId,
    required this.targetLabel,
  })  : contentType = null,
        contentId = null;

  const ReportDialog.content({
    super.key,
    required String this.contentType,
    required String this.contentId,
    required this.targetLabel,
  }) : userId = null;

  static Future<void> show(
    BuildContext context, {
    String? userId,
    String? contentType,
    String? contentId,
    required String targetLabel,
  }) {
    return showDialog(
      context: context,
      builder: (_) => userId != null
          ? ReportDialog.user(userId: userId, targetLabel: targetLabel)
          : ReportDialog.content(
              contentType: contentType!,
              contentId: contentId!,
              targetLabel: targetLabel,
            ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final ReportService _service = ReportService();
  final TextEditingController _details = TextEditingController();
  String? _reason;
  bool _submitting = false;

  // Backend-accepted report reason enum.
  static const _reasons = <String, String>{
    'spam': 'Spam',
    'harassment': 'Harassment or bullying',
    'hate_speech': 'Hate speech',
    'violence': 'Violence or threats',
    'misinformation': 'Misinformation',
    'nudity': 'Nudity or sexual content',
    'copyright': 'Copyright infringement',
    'other': 'Something else',
  };

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    final details = _details.text.trim().isEmpty ? null : _details.text.trim();
    final res = widget.userId != null
        ? await _service.reportUser(userId: widget.userId!, reason: _reason!, details: details)
        : await _service.reportContent(
            contentType: widget.contentType!,
            contentId: widget.contentId!,
            reason: _reason!,
            details: details,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.isSuccess
            ? 'Report submitted. Thanks for keeping SwiftSnap safe.'
            : res.errorMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SwiftSnapTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report ${widget.targetLabel}',
                style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Tell us what\'s wrong. Reports are confidential.',
                style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ..._reasons.entries.map((e) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: SwiftSnapTheme.primaryPurple,
                  title: Text(e.value, style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 14)),
                  value: e.key,
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _details,
              maxLines: 3,
              maxLength: 2000,
              style: const TextStyle(color: SwiftSnapTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add details (optional)',
                hintStyle: const TextStyle(color: SwiftSnapTheme.textSecondary),
                filled: true,
                fillColor: SwiftSnapTheme.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwiftSnapTheme.busy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (_reason == null || _submitting) ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
