import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_discount.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

class ClassDiscountText extends StatelessWidget {
  const new({required this.item, this.maxLines, super.key});

  final ClassSummary item;
  final int? maxLines;

  static bool showsFor(ClassSummary item) {
    final discount = item.discount;
    return item.originalPriceLabel != null &&
        discount != null &&
        (discount.forFirstPeople != null || discount.validUntil != null);
  }

  @override
  Widget build(BuildContext context) {
    final discount = item.discount;
    final original = item.originalPriceLabel;
    if (!showsFor(item) || discount == null || original == null) {
      return const SizedBox.shrink();
    }
    final terms = _terms(context, discount);
    final color = Theme.of(context).brightness == Brightness.dark
        ? AppColors.brandBlueOnDark
        : AppColors.tagBlueText;
    final style = context.textTheme.bodySmall?.copyWith(
      color: color,
      fontWeight: FontWeight.w500,
    );

    return Semantics(
      label: '${context.l10n.classDiscountFullPriceLabel(original)}, $terms',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: original,
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                decorationColor: color,
              ),
            ),
            TextSpan(text: ' ($terms)'),
          ],
        ),
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  String _terms(BuildContext context, ClassDiscount discount) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final percent = NumberFormat('0.##', locale).format(discount.percentage);
    final people = discount.forFirstPeople;
    final until = discount.validUntil;
    final date = until == null
        ? null
        : DateFormat('dd MMM', locale).format(until.toLocal());
    if (people != null && date != null) {
      return l10n.classDiscountForFirstPeopleValidTill(percent, people, date);
    }
    if (people != null) {
      return l10n.classDiscountForFirstPeople(percent, people);
    }
    return l10n.classDiscountValidTill(percent, date ?? '');
  }
}
