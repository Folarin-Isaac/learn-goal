import 'package:flutter/material.dart';
import 'package:lengoal/core/motion/entrance.dart';
import 'package:lengoal/core/motion/pressable.dart';
import 'package:lengoal/core/utils/haptics.dart';

class SelectableListCard<T> extends StatelessWidget {
  const new({
    required this.items,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<T> items;
  final String Function(T item) labelOf;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: colorScheme.outlineVariant),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;
          return Entrance(
            index: index,
            child: Pressable(
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  onSelected(item);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelOf(item),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
