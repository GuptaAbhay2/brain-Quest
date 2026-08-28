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
    // Progress fraction calculation (0.0 to 1.0)
    final double progress = maxStars == 0 ? 0.0 : (totalStars / maxStars).clamp(0.0, 1.0);
    final String progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A), // Dark theme background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A374F),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- TOP SECTION (Image Design) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Total Stars
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Stars:',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$totalStars/$maxStars',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 22,
                      color: const Color(0xFFFFD700), // Gold Star color
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFD700),
                    size: 26,
                  ),
                ],
              ),

              // Current Progress Level
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CURRENT\nPROGRESS',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level $currentLevel',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 22,
                      color: const Color(0xFF4DD0E1), // Cyan Level color
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // --- BOTTOM SECTION (Dynamic Progress Bar) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Track Background
                Container(
                  height: 10,
                  color: const Color(0xFF0A0F1D),
                ),
                // Dynamic Filled Bar
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00E5FF), // Cyan Glow
                          Color(0xFFFFD700), // Gold Glow
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Progress Text & Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journey Progress',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$progressPercent%',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF4DD0E1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}