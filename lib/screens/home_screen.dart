import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../utils/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brain Quest')),
      body: Consumer<LevelProvider>(
        builder: (context, levelProvider, _) {
          return Center(
            child: Text(
              'Home content — Step 9 me banayenge\nCurrent Level: ${levelProvider.currentLevelNumber}',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          );
        },
      ),
    );
  }
}