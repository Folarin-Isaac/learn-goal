import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/dashboard/presentation/models/subscription_history_item.dart';

class SubscriptionHistoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      context.l10n.profileSubscriptionHistory,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.r16),
                    ),
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < mockSubscriptionHistory.length;
                          i++
                        ) ...[
                          if (i > 0) const Divider(height: 1),
                          _SubscriptionRow(item: mockSubscriptionHistory[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const new({required this.item});

  final SubscriptionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.label} - ${item.amount}',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(AppSpacing.s4),
                Text(
                  item.date,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (item.isPaid)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDAF2E4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                context.l10n.classDetailsStatusPaid,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0E8C43),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
