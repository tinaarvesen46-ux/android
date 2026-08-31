import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/empty_state_view.dart';

/// Creator earnings and payout status.
///
/// BACKEND CONTRACT (bearer auth):
///   GET /creator/overview -> { balance, currency, pending_payout,
///                              lifetime_earnings, views, payout_status }
///   GET /creator/payouts  -> paginated payout list
///
/// SwiftSnap never displays a fabricated balance. Until the overview endpoint
/// responds, this screen states plainly that no earnings data is available.
class CreatorPanelScreen extends StatelessWidget {
  const CreatorPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          AppTopBar(showBack: true, title: 'Creator panel'),
          Expanded(
            child: EmptyStateView(
              icon: Icons.workspace_premium_outlined,
              title: 'No earnings data',
              subtitle:
                  'Creator earnings are reported by the SwiftSnap backend. Nothing is shown until real figures are returned.',
            ),
          ),
          SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}
