import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';
import 'email_template_editor_screen.dart';

class EmailCampaignsScreen extends StatefulWidget {
  const EmailCampaignsScreen({super.key});

  @override
  State<EmailCampaignsScreen> createState() => _EmailCampaignsScreenState();
}

class _EmailCampaignsScreenState extends State<EmailCampaignsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late final TabController _tabController;

  // Pre-designed exclusive email templates
  final List<EmailTemplate> _templates = [
    EmailTemplate(
      id: 'tpl_welcome',
      name: 'Welcome to SwiftSnap',
      subject: 'Welcome to SwiftSnap – Let\'s Get Vibing! 🎉',
      previewText:
          'Your journey to meaningful connections starts now.',
      htmlContent: '',
      category: TemplateCategory.welcome,
      thumbnailColor: '8B5CF6',
      variables: ['{{username}}', '{{app_url}}', '{{support_email}}'],
      createdAt: DateTime(2024, 1, 1),
    ),
    EmailTemplate(
      id: 'tpl_verify',
      name: 'Email Verification',
      subject: 'Verify your SwiftSnap email address ✅',
      previewText: 'One quick step to secure your account.',
      htmlContent: '',
      category: TemplateCategory.security,
      thumbnailColor: '10B981',
      variables: ['{{username}}', '{{verification_link}}', '{{expires_in}}'],
      createdAt: DateTime(2024, 1, 1),
    ),
    EmailTemplate(
      id: 'tpl_password_reset',
      name: 'Password Reset',
      subject: 'Reset your SwiftSnap password 🔐',
      previewText: 'Someone (hopefully you!) requested a password reset.',
      htmlContent: '',
      category: TemplateCategory.security,
      thumbnailColor: 'EF4444',
      variables: ['{{username}}', '{{reset_link}}', '{{expires_in}}'],
      createdAt: DateTime(2024, 1, 1),
    ),
    EmailTemplate(
      id: 'tpl_new_friend',
      name: 'New Friend Request',
      subject: '{{sender_name}} wants to connect on SwiftSnap 👋',
      previewText: 'You have a new friend request waiting.',
      htmlContent: '',
      category: TemplateCategory.notification,
      thumbnailColor: '3B82F6',
      variables: [
        '{{username}}',
        '{{sender_name}}',
        '{{sender_avatar}}',
        '{{app_url}}'
      ],
      createdAt: DateTime(2024, 1, 1),
    ),
    EmailTemplate(
      id: 'tpl_premium_promo',
      name: 'SwiftSnap+ Promotion',
      subject: 'Unlock the full SwiftSnap experience ✨',
      previewText: 'Limited time offer: 30% off SwiftSnap+ Premium',
      htmlContent: '',
      category: TemplateCategory.promotional,
      thumbnailColor: 'EC4899',
      variables: [
        '{{username}}',
        '{{discount_code}}',
        '{{discount_percent}}',
        '{{offer_expires}}'
      ],
      isPremium: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    EmailTemplate(
      id: 'tpl_winback',
      name: 'Win-Back Campaign',
      subject: 'We miss you on SwiftSnap 💜',
      previewText: 'Your friends are waiting – come back!',
      htmlContent: '',
      category: TemplateCategory.winback,
      thumbnailColor: 'F97316',
      variables: [
        '{{username}}',
        '{{days_inactive}}',
        '{{friend_count}}',
        '{{app_url}}'
      ],
      createdAt: DateTime(2024, 2, 1),
    ),
    EmailTemplate(
      id: 'tpl_app_update',
      name: 'New App Update',
      subject: 'SwiftSnap {{version}} is here! 🚀',
      previewText: 'Exciting new features are waiting for you.',
      htmlContent: '',
      category: TemplateCategory.update,
      thumbnailColor: '06B6D4',
      variables: ['{{version}}', '{{features_list}}', '{{update_link}}'],
      createdAt: DateTime(2024, 2, 15),
    ),
    EmailTemplate(
      id: 'tpl_streak',
      name: 'Streak Achievement',
      subject: '🔥 {{streak_days}} day streak – You\'re on fire!',
      previewText: 'Keep the vibe going – don\'t break your streak!',
      htmlContent: '',
      category: TemplateCategory.notification,
      thumbnailColor: 'FBBF24',
      variables: ['{{username}}', '{{streak_days}}', '{{next_reward}}'],
      createdAt: DateTime(2024, 3, 1),
    ),
  ];

  // Real campaigns are loaded from the backend; no fabricated production data.
  final List<EmailCampaign> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Email Campaigns',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showNewCampaignSheet(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius:
                    BorderRadius.circular(SwiftSnapTheme.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: SwiftSnapTheme.primaryPurple,
          unselectedLabelColor: SwiftSnapTheme.textMuted,
          indicatorColor: SwiftSnapTheme.primaryPurple,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: 'Campaigns (${_campaigns.length})'),
            Tab(text: 'Templates (${_templates.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampaignsTab(),
          _buildTemplatesTab(),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab() {
    if (_campaigns.isEmpty) {
      return _buildEmptyState(
          'No campaigns yet',
          'Create your first email campaign');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        _buildStatsRow(),
        const SizedBox(height: 16),
        ..._campaigns.map(_buildCampaignCard),
      ],
    );
  }

  Widget _buildStatsRow() {
    final sent = _campaigns.where((c) => c.status == CampaignStatus.sent).length;
    final scheduled =
        _campaigns.where((c) => c.status == CampaignStatus.scheduled).length;
    final totalOpens = _campaigns.fold<int>(
        0, (sum, c) => sum + (c.openCount ?? 0));

    return Row(
      children: [
        Expanded(
          child: _statCard('$sent', 'Sent', SwiftSnapTheme.accentGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
              '$scheduled', 'Scheduled', SwiftSnapTheme.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
              _fmtNum(totalOpens), 'Total Opens', SwiftSnapTheme.primaryPurple),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(EmailCampaign campaign) {
    final statusColor = _campaignStatusColor(campaign.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      campaign.templateName,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(campaign.status, statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            campaign.subject,
            style: const TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                size: 14,
                color: SwiftSnapTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                _fmtNum(campaign.recipientCount),
                style: const TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              if (campaign.status == CampaignStatus.sent) ...[
                const SizedBox(width: 16),
                _miniStat(Icons.drafts_rounded, SwiftSnapTheme.primaryPurple,
                    '${campaign.openRate.toStringAsFixed(1)}% open'),
                const SizedBox(width: 10),
                _miniStat(Icons.touch_app_rounded, SwiftSnapTheme.primaryBlue,
                    '${campaign.clickRate.toStringAsFixed(1)}% click'),
              ],
              if (campaign.scheduledAt != null) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: SwiftSnapTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scheduled for ${_fmtDate(campaign.scheduledAt!)}',
                  style: const TextStyle(
                    color: SwiftSnapTheme.primaryBlue,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
          if (campaign.status == CampaignStatus.draft) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SwiftSnapTheme.textSecondary,
                      side: const BorderSide(
                          color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            SwiftSnapTheme.radiusMd),
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(
                          SwiftSnapTheme.radiusMd),
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              SwiftSnapTheme.radiusMd),
                        ),
                      ),
                      onPressed: () => _sendCampaign(campaign),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _templates.length,
      itemBuilder: (_, i) => _buildTemplateCard(_templates[i]),
    );
  }

  Widget _buildTemplateCard(EmailTemplate template) {
    final color =
        Color(int.parse('FF${template.thumbnailColor}', radix: 16));

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                EmailTemplateEditorScreen(template: template),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        decoration: SwiftSnapTheme.glassmorphicDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SwiftSnapTheme.radiusLg),
                ),
              ),
              child: Center(
                child: Icon(
                  _templateIcon(template.category),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                              SwiftSnapTheme.radiusFull),
                        ),
                        child: Text(
                          _categoryLabel(template.category),
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (template.isPremium) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFBBF24),
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${template.variables.length} variables',
                    style: const TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.campaign_rounded,
            size: 64,
            color: SwiftSnapTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewCampaignSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SwiftSnapTheme.radius2Xl),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose a Template',
                  style: TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _templates.length,
                itemBuilder: (_, i) {
                  final template = _templates[i];
                  final color = Color(int.parse(
                      'FF${template.thumbnailColor}',
                      radix: 16));
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            SwiftSnapTheme.radiusMd),
                      ),
                      child: Icon(
                        _templateIcon(template.category),
                        color: color,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      template.name,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _categoryLabel(template.category),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: SwiftSnapTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, animation, __) =>
                              EmailTemplateEditorScreen(
                                  template: template,
                                  launchAsCampaign: true),
                          transitionsBuilder:
                              (_, animation, __, child) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendCampaign(EmailCampaign campaign) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        title: const Text(
          'Send Campaign?',
          style: TextStyle(color: SwiftSnapTheme.textPrimary),
        ),
        content: Text(
          'This will send "${campaign.name}" to ${_fmtNum(campaign.recipientCount)} recipients immediately.',
          style: const TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _adminService.sendCampaign(campaign.id);
                setState(() {
                  final idx =
                      _campaigns.indexWhere((c) => c.id == campaign.id);
                  if (idx != -1) {
                    _campaigns[idx] = EmailCampaign(
                      id: campaign.id,
                      name: campaign.name,
                      templateId: campaign.templateId,
                      templateName: campaign.templateName,
                      subject: campaign.subject,
                      targetAudience: campaign.targetAudience,
                      recipientCount: campaign.recipientCount,
                      status: CampaignStatus.sent,
                      sentAt: DateTime.now(),
                      sentCount: campaign.recipientCount,
                      openCount: 0,
                      clickCount: 0,
                      createdAt: campaign.createdAt,
                    );
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${campaign.name} sent to ${_fmtNum(campaign.recipientCount)} users'),
                    backgroundColor: SwiftSnapTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(CampaignStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }

  Color _campaignStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return SwiftSnapTheme.textMuted;
      case CampaignStatus.scheduled:
        return SwiftSnapTheme.primaryBlue;
      case CampaignStatus.sending:
        return SwiftSnapTheme.accentOrange;
      case CampaignStatus.sent:
        return SwiftSnapTheme.accentGreen;
      case CampaignStatus.failed:
        return SwiftSnapTheme.busy;
    }
  }

  IconData _templateIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.welcome:
        return Icons.celebration_rounded;
      case TemplateCategory.promotional:
        return Icons.local_offer_rounded;
      case TemplateCategory.notification:
        return Icons.notifications_rounded;
      case TemplateCategory.security:
        return Icons.security_rounded;
      case TemplateCategory.update:
        return Icons.system_update_rounded;
      case TemplateCategory.winback:
        return Icons.favorite_rounded;
    }
  }

  String _categoryLabel(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.welcome:
        return 'Welcome';
      case TemplateCategory.promotional:
        return 'Promotional';
      case TemplateCategory.notification:
        return 'Notification';
      case TemplateCategory.security:
        return 'Security';
      case TemplateCategory.update:
        return 'Update';
      case TemplateCategory.winback:
        return 'Win-Back';
    }
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _fmtDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
