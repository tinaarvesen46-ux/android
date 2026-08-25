import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildLoginList(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: SwiftSnapTheme.textPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Login History',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginList() {
    final List<Map<String, dynamic>> loginHistory = [
      {
        'device': 'iPhone 14 Pro',
        'location': 'San Francisco, CA',
        'time': 'Just now',
        'ip': '192.168.1.100',
        'isCurrent': true,
        'icon': Icons.phone_iphone_rounded,
      },
      {
        'device': 'MacBook Pro',
        'location': 'San Francisco, CA',
        'time': '2 hours ago',
        'ip': '192.168.1.101',
        'isCurrent': false,
        'icon': Icons.laptop_mac_rounded,
      },
      {
        'device': 'iPad Air',
        'location': 'San Francisco, CA',
        'time': '1 day ago',
        'ip': '192.168.1.102',
        'isCurrent': false,
        'icon': Icons.tablet_mac_rounded,
      },
      {
        'device': 'Windows PC',
        'location': 'Los Angeles, CA',
        'time': '3 days ago',
        'ip': '192.168.2.50',
        'isCurrent': false,
        'icon': Icons.desktop_windows_rounded,
      },
      {
        'device': 'Chrome Browser',
        'location': 'New York, NY',
        'time': '1 week ago',
        'ip': '192.168.3.75',
        'isCurrent': false,
        'icon': Icons.web_rounded,
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final login = loginHistory[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              index == 0 ? 0 : 8,
              16,
              index == loginHistory.length - 1 ? 0 : 8,
            ),
            child: _buildLoginItem(context, login),
          ).animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0);
        },
        childCount: loginHistory.length,
      ),
    );
  }

  Widget _buildLoginItem(BuildContext context, Map<String, dynamic> login) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: login['isCurrent']
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: login['isCurrent']
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        )
                      : SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: login['isCurrent']
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  login['icon'],
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            login['device'],
                            style: const TextStyle(
                              color: SwiftSnapTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (login['isCurrent']) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: SwiftSnapTheme.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          login['time'],
                          style: TextStyle(
                            color: SwiftSnapTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: SwiftSnapTheme.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      login['location'],
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: SwiftSnapTheme.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IP: ${login['ip']}',
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!login['isCurrent']) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 62),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showRemoveDialog(context, login['device']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: SwiftSnapTheme.busy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SwiftSnapTheme.busy.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, color: SwiftSnapTheme.busy, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Log Out Device',
                        style: TextStyle(
                          color: SwiftSnapTheme.busy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, String device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out Device?',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will log out $device from your account.',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: SwiftSnapTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$device logged out successfully'),
                  backgroundColor: SwiftSnapTheme.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: SwiftSnapTheme.busy),
            ),
          ),
        ],
      ),
    );
  }
}
