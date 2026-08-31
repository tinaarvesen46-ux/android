import 'package:flutter/material.dart';

/// Backend-owned account badge. Sourced strictly from `User.role` /
/// `User.roleLabel` (Laravel `User::getRoleAttribute()`) — never
/// client-assigned. Renders nothing for the plain `user` role.
class RoleBadge extends StatelessWidget {
  final String role;
  final String roleLabel;

  /// Icon-only, sized to sit inline next to a display name.
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    required this.roleLabel,
    this.compact = true,
  });

  _RoleStyle? get _style {
    switch (role) {
      case 'administrator':
        return const _RoleStyle(Icons.shield_rounded, Color(0xFFE53E5E));
      case 'moderator':
        return const _RoleStyle(Icons.shield_moon_rounded, Color(0xFF2FB8A6));
      case 'support':
        return const _RoleStyle(Icons.support_agent_rounded, Color(0xFF4C8DFF));
      case 'creator':
        return const _RoleStyle(Icons.star_rounded, Color(0xFFF5B93D));
      case 'verified':
        return const _RoleStyle(Icons.verified_rounded, Color(0xFF4C8DFF));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    if (style == null) return const SizedBox.shrink();

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(style.icon, size: 15, color: style.color),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 13, color: style.color),
            const SizedBox(width: 4),
            Text(
              roleLabel.isNotEmpty ? roleLabel : role,
              style: TextStyle(
                color: style.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleStyle {
  final IconData icon;
  final Color color;
  const _RoleStyle(this.icon, this.color);
}
