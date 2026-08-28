import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ChapterBanner extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int startLevel;
  final int endLevel;
  final bool isLocked;
  final bool isFirst;

  const ChapterBanner({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.startLevel,
    required this.endLevel,
    required this.isLocked,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.45 : 1.0,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, isFirst ? 4 : 26, 20, 14),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.16), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading2.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Level $startLevel – $endLevel',
                    style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              Icon(Icons.lock_rounded, color: color.withOpacity(0.6), size: 16),
            ],
          ],
        ),
      ),
    );
  }
}