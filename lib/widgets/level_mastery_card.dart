import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class LevelMasteryCard extends StatelessWidget {
  final int totalLevels;
  final int levelsCompleted;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  const LevelMasteryCard({
    super.key,
    required this.totalLevels,
    required this.levelsCompleted,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalLevels == 0 ? 0.0 : levelsCompleted / totalLevels;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL MASTERY',
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$levelsCompleted', style: AppTextStyles.heading1.copyWith(fontSize: 22)),
                        Text('/ $totalLevels', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _starRow(3, threeStarCount),
                    const SizedBox(height: 10),
                    _starRow(2, twoStarCount),
                    const SizedBox(height: 10),
                    _starRow(1, oneStarCount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starRow(int starCount, int levelCount) {
    return Row(
      children: [
        Row(
          children: List.generate(3, (i) {
            return Icon(
              i < starCount ? Icons.star_rounded : Icons.star_border_rounded,
              color: i < starCount ? AppColors.star : AppColors.textMuted.withOpacity(0.3),
              size: 14,
            );
          }),
        ),
        const Spacer(),
        Text('$levelCount levels', style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }
}