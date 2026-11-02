import 'dart:async';

import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/presentation/bloc/payment_history/payment_history_cubit.dart';

class SubscriptionHistoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<PaymentHistoryCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
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
                const Expanded(child: _HistoryBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
      builder: (context, state) {
        final cubit = context.read<PaymentHistoryCubit>();
        switch (state.status) {
          case PaymentHistoryStatus.initial:
          case PaymentHistoryStatus.loading:
            return const _HistorySkeleton();
          case PaymentHistoryStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? context.l10n.errorGeneric,
              onRetry: () {
                AppHaptics.selection();
                unawaited(cubit.load());
              },
              retryLabel: context.l10n.commonRetry,
            );
          case PaymentHistoryStatus.loaded:
            break;
        }
        return RefreshIndicator(
          onRefresh: () => cubit.load(forceRefresh: true),
          child: state.records.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Text(
                          context.l10n.subscriptionHistoryEmpty,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.r16),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < state.records.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _SubscriptionRow(record: state.records[i]),
                        ],
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const new({required this.record});

  final PaymentRecord record;

  static final _amount = NumberFormat('#,##0.##');
  static final _date = DateFormat('dd/MM/yy');

  @override
  Widget build(BuildContext context) {
    final date = record.paymentDate;
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
                  '${record.cohortName} - NGN ${_amount.format(record.amount)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (date != null) ...[
                  const Gap(AppSpacing.s4),
                  Text(
                    _date.format(date),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (record.isSuccessful) ...[
            const Gap(AppSpacing.s8),
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
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(AppSpacing.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 180, height: 16),
                          Gap(AppSpacing.s8),
                          SkeletonBox(width: 70),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 56, height: 30, radius: 999),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
