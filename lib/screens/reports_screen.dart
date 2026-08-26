import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _service = ReportService();
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.myReports();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _reports = res.data ?? [];
      } else {
        _error = res.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('My Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_reports.isEmpty) {
      return const Center(
        child: Text('No reports', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = _reports[i];
        final status = '${r['status'] ?? 'pending'}';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Icon(
                r['kind'] == 'content' ? Icons.flag_rounded : Icons.person_off_rounded,
                color: SwiftSnapTheme.primaryPurple,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r['reason'] ?? r['kind'] ?? 'Report'}',
                      style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    if (r['created_at'] != null)
                      Text('${r['created_at']}',
                          style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: const TextStyle(color: SwiftSnapTheme.primaryPurple, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
