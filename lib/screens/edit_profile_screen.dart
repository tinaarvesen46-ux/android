import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _pronounsController;
  late TextEditingController _locationController;
  
  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final user = provider.currentUser;
    
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _pronounsController = TextEditingController(text: user?.pronouns ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _pronounsController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  void _saveProfile() {
    final provider = context.read<AppProvider>();
    provider.updateUserProfile(
      displayName: _nameController.text,
      bio: _bioController.text,
      pronouns: _pronounsController.text,
      location: _locationController.text,
    );
    
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: SwiftSnapTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Display Name',
                      icon: Icons.person_rounded,
                      hint: 'Your name',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      icon: Icons.edit_note_rounded,
                      hint: 'Tell us about yourself',
                      maxLines: 4,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _pronounsController,
                      label: 'Pronouns (Optional)',
                      icon: Icons.wc_rounded,
                      hint: 'e.g. she/her, he/him, they/them',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location (Optional)',
                      icon: Icons.location_on_rounded,
                      hint: 'Your city or country',
                    ),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: SwiftSnapTheme.textPrimary,
            ),
          ),
          const Text(
            'Edit Profile',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarSection() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        if (user == null) return const SizedBox();
        
        return Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SwiftSnapTheme.primaryGradient,
                      boxShadow: SwiftSnapTheme.glowShadow(
                        SwiftSnapTheme.primaryPurple,
                        intensity: 0.3,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().scale(duration: 300.ms),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showAvatarOptions();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: SwiftSnapTheme.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SwiftSnapTheme.backgroundDark,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
            ),
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: SwiftSnapTheme.textMuted,
              ),
              prefixIcon: Icon(
                icon,
                color: SwiftSnapTheme.textMuted,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterStyle: TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: SwiftSnapTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: SwiftSnapTheme.glowShadow(
            SwiftSnapTheme.primaryPurple,
            intensity: 0.3,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
  
  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildAvatarOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(height: 12),
            _buildAvatarOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(height: 12),
            _buildAvatarOption(
              icon: Icons.delete_rounded,
              label: 'Remove Photo',
              color: SwiftSnapTheme.busy,
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? SwiftSnapTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color ?? SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
