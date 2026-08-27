import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/rank_system.dart';

class PlayerRankCard extends StatelessWidget {
  final int totalStars;
  final int maxStars;

  const PlayerRankCard({super.key, required this.totalStars, required this.maxStars});

  @override
  Widget build(BuildContext context) {
    final tiers = RankSystem.tiers(maxStars);
    final rankIndex = RankSystem.getRankIndex(totalStars, tiers);
    final currentRank = tiers[rankIndex];
    final nextRank = rankIndex < tiers.length - 1 ? tiers[rankIndex + 1] : null;

    double progress = 1.0;
    String progressLabel = '👑 MAX';
    if (nextRank != null) {
      final span = nextRank.minStars - currentRank.minStars;
      progress = span == 0 ? 1.0 : ((totalStars - currentRank.minStars) / span).clamp(0.0, 1.0);
      final starsToGo = nextRank.minStars - totalStars;
      progressLabel = '$starsToGo⭐ to go';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [currentRank.color.withOpacity(0.22), AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: currentRank.color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: currentRank.color.withOpacity(0.2),
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
              gradient: LinearGradient(
                colors: [currentRank.color, currentRank.color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: currentRank.color.withOpacity(0.5), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: Icon(currentRank.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            currentRank.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(fontSize: 15, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 70,
              child: Stack(
                children: [
                  Container(height: 6, color: AppColors.background),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(height: 6, color: currentRank.color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            progressLabel,
            style: AppTextStyles.body.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: currentRank.color,
            ),
          ),
        ],
      ),
    );
  }
}