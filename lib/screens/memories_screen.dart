import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/story_model.dart';

/// Memories = the authenticated user's own posted stories, loaded from the
/// Laravel backend via StoryService (see AppProvider.loadInitialData).
///
/// NOTE: the backend does not expose a dedicated `/memories` endpoint, so
/// Memories are derived from the user's own stories. If/when a real memories
/// endpoint is added, swap `provider.stories.where((s) => s.isOwn)` for it.
class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final memories = provider.stories.where((s) => s.isOwn).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(context),
                _buildInfoCard(),
                if (memories.isEmpty)
                  _buildEmptyState()
                else
                  _buildMemoriesGrid(memories),
                const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: SwiftSnapTheme.textPrimary, size: 18),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Memories',
                  style: TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: SwiftSnapTheme.textPrimary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            SwiftSnapTheme.primaryPurple.withOpacity(0.15),
            SwiftSnapTheme.primaryPink.withOpacity(0.1),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Special Moments',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Relive your favorite stories and memories',
                    style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_album_outlined,
                  color: SwiftSnapTheme.textMuted, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'No memories yet',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stories you post will be saved here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoriesGrid(List<StoryModel> memories) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final memory = memories[index];
            return _buildMemoryCard(memory)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          },
          childCount: memories.length,
        ),
      ),
    );
  }

  Widget _buildMemoryCard(StoryModel memory) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: memory.mediaUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: SwiftSnapTheme.surfaceColor),
                errorWidget: (context, url, error) => Container(
                  color: SwiftSnapTheme.surfaceColor,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: SwiftSnapTheme.textMuted),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${memory.viewerCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.caption?.isNotEmpty == true ? memory.caption! : 'Memory',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdAt),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
