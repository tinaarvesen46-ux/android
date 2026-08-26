import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';

class EmailTemplateEditorScreen extends StatefulWidget {
  final EmailTemplate template;
  final bool launchAsCampaign;

  const EmailTemplateEditorScreen({
    super.key,
    required this.template,
    this.launchAsCampaign = false,
  });

  @override
  State<EmailTemplateEditorScreen> createState() =>
      _EmailTemplateEditorScreenState();
}

class _EmailTemplateEditorScreenState
    extends State<EmailTemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late final TabController _tabController;

  // Campaign setup fields
  final _campaignNameController = TextEditingController();
  final _subjectController = TextEditingController();
  String _selectedAudience = 'all_users';
  DateTime? _scheduledAt;
  bool _saving = false;

  // Variable values for preview
  late final Map<String, TextEditingController> _variableControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _subjectController.text = widget.template.subject;
    _campaignNameController.text = '${widget.template.name} Campaign';

    _variableControllers = {
      for (final v in widget.template.variables)
        v: TextEditingController(text: _defaultValue(v)),
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _campaignNameController.dispose();
    _subjectController.dispose();
    for (final c in _variableControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _defaultValue(String variable) {
    switch (variable) {
      case '{{username}}':
        return 'Alex';
      case '{{verification_link}}':
        return 'https://swiftsnap.com/verify/abc123';
      case '{{reset_link}}':
        return 'https://swiftsnap.com/reset/xyz789';
      case '{{expires_in}}':
        return '24 hours';
      case '{{app_url}}':
        return 'https://swiftsnap.com';
      case '{{support_email}}':
        return 'support@swiftsnap.com';
      case '{{sender_name}}':
        return 'SwiftSnap Team';
      case '{{sender_avatar}}':
        return 'https://swiftsnap.com/logo.png';
      case '{{discount_code}}':
        return 'SUMMER30';
      case '{{discount_percent}}':
        return '30';
      case '{{offer_expires}}':
        return 'July 31, 2025';
      case '{{days_inactive}}':
        return '30';
      case '{{friend_count}}':
        return '12';
      case '{{version}}':
        return '2.0';
      case '{{features_list}}':
        return 'Reactions, Voice Messages, AR Filters';
      case '{{update_link}}':
        return 'https://swiftsnap.com/update';
      case '{{streak_days}}':
        return '30';
      case '{{next_reward}}':
        return 'Exclusive Badge';
      default:
        return variable.replaceAll('{{', '').replaceAll('}}', '');
    }
  }

  String _buildPreviewSubject() {
    var subject = widget.template.subject;
    for (final entry in _variableControllers.entries) {
      subject = subject.replaceAll(entry.key, entry.value.text);
    }
    return subject;
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(
        int.parse('FF${widget.template.thumbnailColor}', radix: 16));

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.template.name,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.launchAsCampaign
                  ? 'New Campaign'
                  : 'Template Preview',
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.launchAsCampaign)
            _saving
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: SwiftSnapTheme.primaryPurple,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _createCampaign,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: SwiftSnapTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(
                            SwiftSnapTheme.radiusFull),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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
            const Tab(text: 'Preview'),
            const Tab(text: 'Variables'),
            if (widget.launchAsCampaign)
              const Tab(text: 'Settings')
            else
              const Tab(text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPreviewTab(color),
          _buildVariablesTab(color),
          widget.launchAsCampaign
              ? _buildCampaignSettingsTab()
              : _buildInfoTab(),
        ],
      ),
    );
  }

  Widget _buildPreviewTab(Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Email envelope preview
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Email header bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(SwiftSnapTheme.radiusLg),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBBF24),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _buildPreviewSubject(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Email body
                _buildEmailBody(color),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Email metadata
          Container(
            padding: const EdgeInsets.all(14),
            decoration: SwiftSnapTheme.glassmorphicDecoration(),
            child: Column(
              children: [
                _metaRow('From', 'SwiftSnap <noreply@swiftsnap.com>'),
                _metaRow('Subject', _buildPreviewSubject()),
                _metaRow('Preview Text', widget.template.previewText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailBody(Color color) {
    String _replaceVars(String text) {
      var result = text;
      for (final entry in _variableControllers.entries) {
        result = result.replaceAll(entry.key, entry.value.text);
      }
      return result;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo area
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius:
                    BorderRadius.circular(SwiftSnapTheme.radiusMd),
              ),
              child: const Text(
                'SwiftSnap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Hero image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: Center(
              child: Icon(
                _categoryIcon(widget.template.category),
                size: 48,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Dynamic content based on category
          Text(
            _getEmailHeadline(),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getEmailBody(_replaceVars),
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // CTA Button
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.circular(SwiftSnapTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              child: Text(
                _getCTALabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'SwiftSnap · support@swiftsnap.com\n© 2025 Nexa-Group. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariablesTab(Color color) {
    if (widget.template.variables.isEmpty) {
      return const Center(
        child: Text(
          'This template has no variables',
          style: TextStyle(color: SwiftSnapTheme.textMuted),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Customize these variables to preview the email',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...widget.template.variables.map((variable) {
          final controller = _variableControllers[variable]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variable,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: SwiftSnapTheme.glassmorphicDecoration(
                    borderRadius: SwiftSnapTheme.radiusMd,
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCampaignSettingsTab() {
    final audiences = [
      ('all_users', 'All Users', '142,850 recipients'),
      ('active_30_days', 'Active Last 30 Days', '89,330 recipients'),
      ('inactive_30_days', 'Inactive 30+ Days', '12,400 recipients'),
      ('premium_users', 'SwiftSnap+ Users', '3,280 recipients'),
      ('new_users_7_days', 'New (Last 7 Days)', '8,730 recipients'),
      ('staff_only', 'Staff Only', '12 recipients'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Name',
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: SwiftSnapTheme.glassmorphicDecoration(
              borderRadius: SwiftSnapTheme.radiusMd,
            ),
            child: TextField(
              controller: _campaignNameController,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email Subject',
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: SwiftSnapTheme.glassmorphicDecoration(
              borderRadius: SwiftSnapTheme.radiusMd,
            ),
            child: TextField(
              controller: _subjectController,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Target Audience',
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...audiences.map((aud) {
            final selected = _selectedAudience == aud.$1;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedAudience = aud.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected ? SwiftSnapTheme.primaryGradient : null,
                  color: selected ? null : SwiftSnapTheme.surfaceColor,
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusMd),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected
                          ? Colors.white
                          : SwiftSnapTheme.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        aud.$2,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : SwiftSnapTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      aud.$3,
                      style: TextStyle(
                        color: selected
                            ? Colors.white70
                            : SwiftSnapTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'Schedule',
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _scheduledAt = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: _scheduledAt == null
                          ? SwiftSnapTheme.primaryGradient
                          : null,
                      color: _scheduledAt == null
                          ? null
                          : SwiftSnapTheme.surfaceColor,
                      borderRadius:
                          BorderRadius.circular(SwiftSnapTheme.radiusMd),
                    ),
                    child: Text(
                      'Send Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _scheduledAt == null
                            ? Colors.white
                            : SwiftSnapTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: SwiftSnapTheme.primaryPurple,
                            surface: SwiftSnapTheme.backgroundCard,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => _scheduledAt = date);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: _scheduledAt != null
                          ? SwiftSnapTheme.primaryGradient
                          : null,
                      color: _scheduledAt != null
                          ? null
                          : SwiftSnapTheme.surfaceColor,
                      borderRadius:
                          BorderRadius.circular(SwiftSnapTheme.radiusMd),
                    ),
                    child: Text(
                      _scheduledAt != null
                          ? 'Scheduled'
                          : 'Schedule Later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _scheduledAt != null
                            ? Colors.white
                            : SwiftSnapTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: SwiftSnapTheme.glassmorphicDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Template Details',
                  style: TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _metaRow('ID', widget.template.id),
                _metaRow('Category', _categoryLabel(widget.template.category)),
                _metaRow(
                    'Variables',
                    widget.template.variables.isEmpty
                        ? 'None'
                        : widget.template.variables.join(', ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createCampaign() {
    if (_campaignNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a campaign name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    _adminService.createCampaign({
      'name': _campaignNameController.text,
      'template_id': widget.template.id,
      'subject': _subjectController.text,
      'audience': _selectedAudience,
      'scheduled_at': _scheduledAt?.toIso8601String(),
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _scheduledAt != null
                  ? 'Campaign scheduled successfully'
                  : 'Campaign created and sent!',
            ),
            backgroundColor: SwiftSnapTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  IconData _categoryIcon(TemplateCategory category) {
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

  String _getEmailHeadline() {
    switch (widget.template.category) {
      case TemplateCategory.welcome:
        return 'Welcome to SwiftSnap! 🎉';
      case TemplateCategory.promotional:
        return 'Exclusive Offer Just for You ✨';
      case TemplateCategory.notification:
        return 'You Have a New Notification 🔔';
      case TemplateCategory.security:
        return 'Security Action Required 🔐';
      case TemplateCategory.update:
        return 'Exciting Updates Are Here 🚀';
      case TemplateCategory.winback:
        return 'We Miss You! Come Back 💜';
    }
  }

  String _getEmailBody(String Function(String) replaceVars) {
    switch (widget.template.category) {
      case TemplateCategory.welcome:
        return 'Hi ${replaceVars('{{username}}')}, welcome to the most vibrant social platform on the planet! Your journey to meaningful connections starts now. Discover new friends, share your stories, and let your personality shine through.\n\nWe\'re thrilled to have you here!';
      case TemplateCategory.promotional:
        return 'Hi ${replaceVars('{{username}}')}, we have an exclusive offer just for you! Use code ${replaceVars('{{discount_code}}')} to get ${replaceVars('{{discount_percent}}')}% off SwiftSnap+ Premium.\n\nOffer expires ${replaceVars('{{offer_expires}}')}. Don\'t miss out!';
      case TemplateCategory.notification:
        return 'Hi ${replaceVars('{{username}}')}, you have new activity on SwiftSnap. ${replaceVars('{{sender_name}}')} wants to connect with you!\n\nOpen the app to respond and keep your connections growing.';
      case TemplateCategory.security:
        return 'Hi ${replaceVars('{{username}}')}, we received a request to access your account. If this was you, please click the button below to proceed.\n\nThis link expires in ${replaceVars('{{expires_in}}')}. If you didn\'t request this, please ignore this email.';
      case TemplateCategory.update:
        return 'Great news! SwiftSnap ${replaceVars('{{version}}')} is now available with amazing new features:\n\n${replaceVars('{{features_list}}')}\n\nUpdate now to experience the best SwiftSnap yet!';
      case TemplateCategory.winback:
        return 'Hi ${replaceVars('{{username}}')}, it\'s been ${replaceVars('{{days_inactive}}')} days since you last vibed! Your ${replaceVars('{{friend_count}}')} friends are posting stories and sending messages.\n\nCome back and see what you\'ve been missing!';
    }
  }

  String _getCTALabel() {
    switch (widget.template.category) {
      case TemplateCategory.welcome:
        return 'Start Vibing →';
      case TemplateCategory.promotional:
        return 'Claim Your Offer →';
      case TemplateCategory.notification:
        return 'View Notification →';
      case TemplateCategory.security:
        return 'Verify Now →';
      case TemplateCategory.update:
        return 'Update SwiftSnap →';
      case TemplateCategory.winback:
        return 'Come Back →';
    }
  }
}
