import 'package:flutter/material.dart';
import '../models/level_progress.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class LevelPathTile extends StatefulWidget {
  final LevelProgress progress;
  final bool isCurrent;
  final bool showTopConnector;
  final bool topConnectorBright;
  final bool statsOnLeft;
  final double lockedOpacity;
  final VoidCallback? onTap;

  const LevelPathTile({
    super.key,
    required this.progress,
    required this.isCurrent,
    required this.showTopConnector,
    required this.topConnectorBright,
    required this.statsOnLeft,
    this.lockedOpacity = 1.0,
    this.onTap,
  });

  @override
  State<LevelPathTile> createState() => _LevelPathTileState();
}

class _LevelPathTileState extends State<LevelPathTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
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
    return Column(
      children: [
        if (widget.showTopConnector)
          Container(
            width: 3,
            height: 32,
            color: widget.topConnectorBright
                ? AppColors.currentLevelGlow.withOpacity(0.8)
                : AppColors.lockedLevel,
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: widget.isCurrent ? 14 : 2),
          child: Opacity(
            opacity: widget.isCurrent ? 1.0 : widget.lockedOpacity,
            child: widget.isCurrent ? _buildCurrentCircle() : _buildRow(),
          ),
        ),
      ],
    );
  }

  Widget _buildRow() {
    final isLocked = !widget.progress.isUnlocked;
    final isCompleted = widget.progress.isCompleted;
    final circle = _buildSmallCircle(isLocked, isCompleted);

    Widget leftContent = const SizedBox.shrink();
    Widget rightContent = const SizedBox.shrink();

    if (isCompleted) {
      final starsWidget = _buildStarsRow();
      final timeWidget = _buildTimeText();
      if (widget.statsOnLeft) {
        leftContent = starsWidget;
        rightContent = timeWidget;
      } else {
        leftContent = timeWidget;
        rightContent = starsWidget;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(padding: const EdgeInsets.only(right: 12), child: leftContent),
          ),
        ),
        GestureDetector(onTap: isLocked ? null : widget.onTap, child: circle),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.only(left: 12), child: rightContent),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCircle(bool isLocked, bool isCompleted) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(
          color: isLocked ? AppColors.lockedLevel : AppColors.currentLevelGlow,
          width: 2,
        ),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: AppColors.currentLevelGlow.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Center(
        child: isLocked
            ? Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 18)
            : Text(
                '${widget.progress.levelNumber}',
                style: AppTextStyles.levelNumber.copyWith(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildStarsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < widget.progress.starsEarned ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.star,
          size: 16,
        );
      }),
    );
  }

  Widget _buildTimeText() {
    return Text(
      widget.progress.bestTimeSeconds != null ? '${widget.progress.bestTimeSeconds}s' : '--',
      style: AppTextStyles.body.copyWith(fontSize: 13),
    );
  }

  Widget _buildCurrentCircle() {
    Widget circle = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: AppColors.currentLevelGlow, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.currentLevelGlow.withOpacity(0.55),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL ${widget.progress.levelNumber}',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PLAY',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.currentLevelGlow,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    if (_pulseController != null) {
      circle = AnimatedBuilder(
        animation: _pulseController!,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController!.value * 0.04);
          return Transform.scale(scale: scale, child: child);
        },
        child: circle,
      );
    }

    return GestureDetector(onTap: widget.onTap, child: circle);
  }
}