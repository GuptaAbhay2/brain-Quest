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
    final progress = maxStars == 0 ? 0.0 : totalStars / maxStars;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.surfaceLight, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.star,
                  value: '$totalStars',
                  suffix: '/$maxStars',
                  label: 'Total Stars',
                ),
              ),
              Container(width: 1, height: 52, color: AppColors.textMuted.withOpacity(0.25)),
              Expanded(
                child: _statTile(
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.secondary,
                  value: '$currentLevel',
                  suffix: '',
                  label: 'Current Level',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.star),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% journey complete',
            style: AppTextStyles.body.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String suffix,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.15)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: AppTextStyles.heading1.copyWith(fontSize: 22)),
              TextSpan(text: suffix, style: AppTextStyles.body.copyWith(fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }
}