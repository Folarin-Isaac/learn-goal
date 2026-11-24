import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lengoal/gen/assets.gen.dart';

class AppBackButton extends StatelessWidget {
  const new({super.key, this.onPressed, this.padding = defaultPadding});

  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  static const EdgeInsets defaultPadding = EdgeInsets.only(
    right: 20,
    top: 14,
    bottom: 14,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final handler =
        onPressed ??
        () {
          if (context.canPop()) context.pop();
        };

    return GestureDetector(
      onTap: handler,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: padding,
        child: Assets.icons.backArrowIcon.svg(
          width: 12,
          height: 16,
          colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
        ),
      ),
    );
  }
}
