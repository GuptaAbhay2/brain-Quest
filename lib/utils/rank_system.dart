import 'package:flutter/material.dart';
import 'app_colors.dart';

class RankInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int minStars;

  const RankInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.minStars,
  });
}

class RankSystem {
  RankSystem._();

  static List<RankInfo> tiers(int maxPossibleStars) {
    return [
      RankInfo(name: 'Rookie', icon: Icons.eco_rounded, color: const Color(0xFF8BC34A), minStars: 0),
      RankInfo(name: 'Explorer', icon: Icons.explore_rounded, color: AppColors.secondary, minStars: (maxPossibleStars * 0.10).round()),
      RankInfo(name: 'Strategist', icon: Icons.psychology_rounded, color: AppColors.primary, minStars: (maxPossibleStars * 0.30).round()),
      RankInfo(name: 'Pro', icon: Icons.bolt_rounded, color: const Color(0xFFFF9F1C), minStars: (maxPossibleStars * 0.55).round()),
      RankInfo(name: 'Master', icon: Icons.emoji_events_rounded, color: AppColors.star, minStars: (maxPossibleStars * 0.80).round()),
      RankInfo(name: 'Legend', icon: Icons.military_tech_rounded, color: const Color(0xFFFF6B9D), minStars: maxPossibleStars),
    ];
  }

  static int getRankIndex(int totalStars, List<RankInfo> allTiers) {
    int index = 0;
    for (int i = 0; i < allTiers.length; i++) {
      if (totalStars >= allTiers[i].minStars) index = i;
    }
    return index;
  }
}