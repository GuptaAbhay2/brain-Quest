import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class GameSummaryCard extends StatelessWidget {
  final int totalStars;
  final int maxStars;
  final int currentLevel;
  final int currentStreak;

  const GameSummaryCard({
    super.key,
    required this.totalStars,
    required this.maxStars,
    required this.currentLevel,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxStars == 0 ? 0.0 : totalStars / maxStars;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PROGRESS',
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.star,
                  value: '$totalStars',
                  suffix: '/$maxStars',
                  label: 'Stars',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _statTile(
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.secondary,
                  value: '$currentLevel',
                  suffix: '',
                  label: 'Level',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _statTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFFF6B35),
                  value: '$currentStreak',
                  suffix: '',
                  label: 'Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(progress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journey Progress',
                style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                '$progressPercent%',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.textMuted.withOpacity(0.2),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.15)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: AppTextStyles.heading2.copyWith(fontSize: 19)),
              TextSpan(text: suffix, style: AppTextStyles.body.copyWith(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(height: 10, color: AppColors.background),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}