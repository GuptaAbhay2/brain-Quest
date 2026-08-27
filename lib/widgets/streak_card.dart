import 'package:flutter/material.dart';
import '../utils/app_text_styles.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            alignment: Alignment.center,
            child: const Text('🔥', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 10),
          Text(
            '$streakDays',
            style: AppTextStyles.heading1.copyWith(fontSize: 26, color: Colors.white),
          ),
          Text(
            'Day Streak',
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}