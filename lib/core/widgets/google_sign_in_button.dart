import 'package:flutter/material.dart';
import 'package:lengoal/core/widgets/app_button.dart';
import 'package:lengoal/gen/assets.gen.dart';
import 'package:lengoal/l10n/l10n.dart';

class GoogleSignInButton extends StatelessWidget {
  const new({required this.onPressed, super.key, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.l10n.socialSignInGoogle,
      isOutlined: true,
      isLoading: isLoading,
      onPressed: onPressed,
      icon: CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white,
        child: Assets.icons.googleIcon.svg(width: 14, height: 14),
      ),
    );
  }
}
