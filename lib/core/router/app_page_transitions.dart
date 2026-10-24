import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageTransitions {
  const new();

  static const Duration _duration = Duration(milliseconds: 320);
  static const Duration _reverseDuration = Duration(milliseconds: 260);

  static Page<T> build<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final fadeOut = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeIn,
        );
        final slideIn =
            Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(fadeOut),
            child: SlideTransition(position: slideIn, child: child),
          ),
        );
      },
    );
  }
}
