import 'package:flutter/material.dart';
import '../models/user_model.dart';

class VerificationBadge extends StatelessWidget {
  final AccountStatus accountStatus;
  final double size;

  const VerificationBadge({
    super.key,
    required this.accountStatus,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (accountStatus == AccountStatus.creator) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFD700),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.star_rounded,
          color: Colors.white,
          size: size * 0.7,
        ),
      );
    } else if (accountStatus == AccountStatus.verified) {
      return Icon(
        Icons.verified_rounded,
        color: const Color(0xFF8B7BF7), // Purple
        size: size,
      );
    }
    
    return const SizedBox.shrink();
  }
}
