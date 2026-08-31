import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';

class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().loadAccountStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Account status'),
          Expanded(
            child: AsyncStateView<AccountStatus>(
              state: provider.status,
              onRetry: provider.loadAccountStatus,
              builder: (status) => ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: status.isGoodStanding
                          ? appColors.success.withValues(alpha: 0.12)
                          : appColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status.isGoodStanding
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: status.isGoodStanding ? appColors.success : appColors.warning,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(
                            status.isGoodStanding
                                ? 'Your account is in good standing.'
                                : 'Status: ${status.status.replaceAll('_', ' ')}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status.warningCount > 0) ...[
                    const SizedBox(height: AppTheme.spacingLg),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text('${status.warningCount} warning(s) on file'),
                    ),
                  ],
                  if (status.suspensionReason != null) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    ListTile(
                      leading: const Icon(Icons.block_rounded),
                      title: Text(status.suspensionReason!),
                      subtitle: status.suspensionEndsAt != null
                          ? Text('Until ${DateFormat.yMMMd().format(status.suspensionEndsAt!)}')
                          : null,
                    ),
                  ],
                  if (status.banReason != null) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    ListTile(
                      leading: const Icon(Icons.gavel_rounded),
                      title: Text(status.banReason!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
