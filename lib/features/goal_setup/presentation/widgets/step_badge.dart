import 'package:flutter/material.dart';

class StepBadge extends StatelessWidget {
  const new({required this.step, required this.totalSteps, super.key});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        '$step/$totalSteps',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
