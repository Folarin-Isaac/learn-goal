import 'package:flutter/material.dart';

class SelectionBreadcrumb extends StatelessWidget {
  const new({required this.crumbs, super.key});

  final List<String> crumbs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < crumbs.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '|',
                style: TextStyle(color: colorScheme.outlineVariant),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  crumbs[i],
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 14, color: colorScheme.primary),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
