import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().loadMyReports();
    });
  }

  Color _statusColor(String status, AppColorsExtension appColors) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return appColors.success;
      case 'rejected':
        return appColors.danger;
      default:
        return appColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'My Reports'),
          Expanded(
            child: AsyncStateView<List<MyReport>>(
              state: provider.reports,
              emptyIcon: Icons.flag_outlined,
              emptyTitle: 'You haven\'t submitted any reports',
              onRetry: provider.loadMyReports,
              builder: (reports) => ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final r = reports[index];
                  return ListTile(
                    leading: Icon(Icons.flag_rounded, color: _statusColor(r.status, appColors)),
                    title: Text(r.reason),
                    subtitle: Text(DateFormat.yMMMd().format(r.createdAt)),
                    trailing: Text(
                      r.status.replaceAll('_', ' '),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: _statusColor(r.status, appColors)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
