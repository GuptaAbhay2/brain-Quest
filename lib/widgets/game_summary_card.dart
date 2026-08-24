import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class GameSummaryCard extends StatelessWidget {
  final int totalStars;
  final int maxStars;
  final int currentLevel;

  const GameSummaryCard({
    super.key,
    required this.totalStars,
    required this.maxStars,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.surfaceLight, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              icon: Icons.star_rounded,
              iconColor: AppColors.star,
              label: 'Total Stars',
              value: '$totalStars/$maxStars',
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.textMuted.withOpacity(0.3)),
          Expanded(
            child: _statColumn(
              icon: Icons.flag_rounded,
              iconColor: AppColors.secondary,
              label: 'Current Level',
              value: '$currentLevel',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.heading2),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }
}