import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/motion/entrance.dart';
import 'package:lengoal/core/motion/pressable.dart';
import 'package:lengoal/core/utils/haptics.dart';

class GoalFilterChips<T> extends StatelessWidget {
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
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Gap(16),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;
          return Entrance(
            index: index,
            offset: const Offset(10, 0),
            child: Pressable(
              child: GestureDetector(
                onTap: () {
                  AppHaptics.selection();
                  onSelected(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labelOf(item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
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
