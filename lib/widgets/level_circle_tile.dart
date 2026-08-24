import 'package:flutter/material.dart';
import '../models/level_progress.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class LevelCircleTile extends StatefulWidget {
  final LevelProgress progress;
  final bool isCurrent;
  final VoidCallback? onTap;

  const LevelCircleTile({
    super.key,
    required this.progress,
    required this.isCurrent,
    this.onTap,
  });

  @override
  State<LevelCircleTile> createState() => _LevelCircleTileState();
}

class _LevelCircleTileState extends State<LevelCircleTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final isLocked = !progress.isUnlocked;
    final isCompleted = progress.isCompleted;
    final isCurrent = widget.isCurrent;
    final double baseSize = isCurrent ? 64 : 52;

    Widget circle = Container(
      width: baseSize,
      height: baseSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked
            ? AppColors.lockedLevel
            : isCompleted
                ? AppColors.completedLevel
                : AppColors.primary,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.currentLevelGlow.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
        border: isCurrent
            ? Border.all(color: AppColors.currentLevelGlow, width: 3)
            : null,
      ),
      child: Center(
        child: isLocked
            ? const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 22)
            : isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
                : Text('${progress.levelNumber}', style: AppTextStyles.levelNumber),
      ),
    );

    if (isCurrent && _pulseController != null) {
      circle = AnimatedBuilder(
        animation: _pulseController!,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController!.value * 0.08);
          return Transform.scale(scale: scale, child: child);
        },
        child: circle,
      );
    }

    return InkWell(
      onTap: isLocked ? null : widget.onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            circle,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Level ${progress.levelNumber}',
                style: isLocked
                    ? AppTextStyles.body
                    : AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ),
            if (isCompleted) _buildStars(progress.starsEarned),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      children: List.generate(3, (i) {
        return Icon(
          i < count ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.star,
          size: 18,
        );
      }),
    );
  }
}