import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final fmt = DateFormat('MMM d, y • h:mm a');

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Sessions'),
          Expanded(
            child: AsyncStateView<List<SecuritySession>>(
              state: provider.sessions,
              emptyIcon: Icons.devices_other_rounded,
              emptyTitle: 'No active sessions',
              onRetry: provider.loadSessions,
              builder: (sessions) => ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return ListTile(
                    leading: Icon(
                      Icons.smartphone_rounded,
                      color: s.isCurrent ? appColors.storyRing : appColors.subtleText,
                    ),
                    title: Text(s.name),
                    subtitle: Text(
                      s.isCurrent
                          ? 'This device'
                          : s.lastUsedAt != null
                              ? 'Last used ${fmt.format(s.lastUsedAt!)}'
                              : 'Created ${fmt.format(s.createdAt)}',
                    ),
                    trailing: s.isCurrent
                        ? null
                        : TextButton(
                            onPressed: () async {
                              final error = await provider.revokeSession(s.id);
                              if (error != null && context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(error)));
                              }
                            },
                            child: const Text('Sign out'),
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
