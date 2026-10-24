import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/gen/assets.gen.dart';

class NumericKeypad extends StatelessWidget {
  const new({required this.onKeyTap, required this.onBackspace, super.key});

  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows) ...[
          _KeypadRow(
            children: [
              for (final key in row)
                _NumericKey(label: key, onTap: () => onKeyTap(key)),
            ],
          ),
          const Gap(16),
        ],
        _KeypadRow(
          children: [
            _NumericKey(label: '.', onTap: () => onKeyTap('.')),
            _NumericKey(label: '0', onTap: () => onKeyTap('0')),
            _NumericKey(
              onTap: onBackspace,
              child: Assets.icons.keypadBackspaceIcon.svg(
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.brandPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        const Gap(20),
      ],
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}

class _NumericKey extends StatelessWidget {
  const new({required this.onTap, this.label, this.child});

  final VoidCallback onTap;
  final String? label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child:
                child ??
                Text(
                  label!,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: AppColors.brandPrimary),
                ),
          ),
        ),
      ),
    );
  }
}
