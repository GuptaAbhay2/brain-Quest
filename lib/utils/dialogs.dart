import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

Future<void> showExitConfirmDialog(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Quit Level?', style: AppTextStyles.heading2),
      content: Text(
        'Is attempt ka progress save nahi hoga.',
        style: AppTextStyles.body,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: AppTextStyles.body),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Quit', style: AppTextStyles.body.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  if (shouldExit == true && context.mounted) {
    Navigator.of(context).pop();
  }
}