import 'package:flutter/material.dart';
import '../models/user_model.dart';

class StaffBadge extends StatelessWidget {
  final StaffRole staffRole;
  final double size;

  const StaffBadge({
    super.key,
    required this.staffRole,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (staffRole == StaffRole.none) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (staffRole) {
      case StaffRole.administrator:
        backgroundColor = const Color(0xFFDC143C); // Crimson red
        iconColor = Colors.white;
        icon = Icons.shield_rounded;
        break;
      case StaffRole.moderator:
        backgroundColor = const Color(0xFF32CD32); // Lime green
        iconColor = Colors.white;
        icon = Icons.security_rounded;
        break;
      case StaffRole.support:
        backgroundColor = const Color(0xFF1E90FF); // Dodger blue
        iconColor = Colors.white;
        icon = Icons.support_agent_rounded;
        break;
      case StaffRole.none:
        return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size * 0.65,
      ),
    );
  }
}
