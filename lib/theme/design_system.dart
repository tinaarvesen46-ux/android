import 'package:flutter/material.dart';
import 'theme.dart';

/// SwiftSnap Design System — shared, responsive foundation so every screen can
/// move toward the slim, compact, edge-to-edge language WITHOUT per-screen
/// magic numbers. Adopt these tokens/primitives across screens incrementally.
///
/// Philosophy: content-first, tight 8px spacing, compact controls, minimal
/// chrome, media > containers, purple as an ACCENT (not a background).

/// 8px-based spacing scale.
class SSGap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii (flatter than before — small, precise).
class SSRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

/// Compact icon sizing.
class SSIcon {
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 26;
}

/// Responsive typography. Sizes scale slightly with the shortest screen side so
/// small phones stay compact and large phones don't look oversized. Always pass
/// through the ambient textScaler for accessibility.
class SSType {
  static double _s(BuildContext c) {
    final w = MediaQuery.of(c).size.shortestSide;
    if (w < 340) return 0.92;   // small phones
    if (w > 430) return 1.04;   // large phones
    return 1.0;
  }

  static TextStyle pageTitle(BuildContext c) => TextStyle(
      fontSize: 23 * _s(c), fontWeight: FontWeight.w700, color: SwiftSnapTheme.textPrimary, letterSpacing: -0.3);
  static TextStyle section(BuildContext c) => TextStyle(
      fontSize: 18 * _s(c), fontWeight: FontWeight.w700, color: SwiftSnapTheme.textPrimary);
  static TextStyle body(BuildContext c) => TextStyle(
      fontSize: 15 * _s(c), fontWeight: FontWeight.w500, color: SwiftSnapTheme.textPrimary);
  static TextStyle meta(BuildContext c) => TextStyle(
      fontSize: 13 * _s(c), color: SwiftSnapTheme.textMuted);
  static TextStyle label(BuildContext c) => TextStyle(
      fontSize: 11 * _s(c), color: SwiftSnapTheme.textMuted, fontWeight: FontWeight.w600);
}

/// Compact, edge-to-edge screen header. Title left, optional trailing actions.
/// Integrates with the status bar via SafeArea(top) instead of a giant header.
class SSHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final bool large;
  const SSHeader({super.key, required this.title, this.actions = const [], this.leading, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(SSGap.lg, SSGap.sm, SSGap.sm, SSGap.sm),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: SSGap.md)],
          Expanded(
            child: Text(title,
                style: large ? SSType.pageTitle(context) : SSType.section(context),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Small, tappable circular icon button — the standard compact action control.
class SSIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final int? badge;
  const SSIconButton({super.key, required this.icon, required this.onTap, this.color, this.badge});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(SSGap.sm),
        child: Stack(clipBehavior: Clip.none, children: [
          Icon(icon, size: SSIcon.md, color: color ?? SwiftSnapTheme.textPrimary),
          if (badge != null && badge! > 0)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 15),
                decoration: const BoxDecoration(color: SwiftSnapTheme.primaryPink, shape: BoxShape.circle),
                child: Text('${badge! > 99 ? '99+' : badge}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Compact section header with optional trailing action (e.g. "See all").
class SSSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SSSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SSGap.lg, SSGap.md, SSGap.sm, SSGap.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: SSType.label(context).copyWith(letterSpacing: 0.8)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Polished, compact empty state (no fabricated content — used when a real API
/// returns nothing).
class SSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const SSEmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SSGap.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: SwiftSnapTheme.textMuted),
          const SizedBox(height: SSGap.md),
          Text(title, style: SSType.body(context), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: SSGap.xs),
            Text(subtitle!, style: SSType.meta(context), textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }
}
