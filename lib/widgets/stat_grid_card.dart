import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class StatGridCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const StatGridCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [iconColor.withOpacity(0.16), AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: iconColor.withOpacity(0.35)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -12,
              top: -12,
              child: Icon(icon, size: 64, color: iconColor.withOpacity(0.14)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.2)),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(height: 14),
                Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                const SizedBox(height: 2),
                Text(label, style: AppTextStyles.body.copyWith(fontSize: 11.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}