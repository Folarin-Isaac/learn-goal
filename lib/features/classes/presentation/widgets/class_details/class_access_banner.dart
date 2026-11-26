import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_access_date.dart';

class ClassAccessBanner extends StatelessWidget {
  const new({required this.until, super.key});

  final DateTime until;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = formatAccessDate(until, locale);
    final message = context.l10n.classDetailsAccessUntil(date);
    final split = message.indexOf(date);
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.onSurface,
    );
    final bold = style?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.noticeAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.noticeAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_rounded,
              size: 20,
              color: AppColors.noticeAmber,
            ),
          ),
          const Gap(AppSpacing.s16),
          Expanded(
            child: Text.rich(
              split < 0
                  ? TextSpan(text: message)
                  : TextSpan(
                      children: [
                        TextSpan(text: message.substring(0, split)),
                        TextSpan(text: date, style: bold),
                        TextSpan(text: message.substring(split + date.length)),
                      ],
                    ),
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
