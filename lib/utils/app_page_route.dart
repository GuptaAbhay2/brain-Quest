import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
        );
}