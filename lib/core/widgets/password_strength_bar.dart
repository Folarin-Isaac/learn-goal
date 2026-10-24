import 'package:flutter/material.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/validators.dart';

class PasswordStrengthBar extends StatelessWidget {
  const new({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox(height: 3);

    final ratio = Validators.passwordStrength(password) / 4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.s4),
      child: Stack(
        children: [
          Container(height: 3, color: Colors.red.shade300),
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(height: 3, color: Colors.green.shade400),
          ),
        ],
      ),
    );
  }
}
