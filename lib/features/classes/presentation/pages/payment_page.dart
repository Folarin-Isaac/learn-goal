import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/pages/payment_success_page.dart';
import 'package:lengoal/features/payments/presentation/bloc/class_payment/class_payment_cubit.dart';
import 'package:lengoal/features/payments/presentation/widgets/paystack_checkout_view.dart';

class PaymentPage extends StatelessWidget {
  const new({required this.detail, super.key});

  final ClassDetail detail;

  @override
  Widget build(BuildContext context) {
    final source = detail.source;
    return BlocProvider(
      create: (_) => getIt<ClassPaymentCubit>(
        param1: source.id,
        param2: source.effectivePrice,
      ),
      child: BlocConsumer<ClassPaymentCubit, ClassPaymentState>(
        listenWhen: (previous, current) =>
            previous.issueCount != current.issueCount ||
            (previous.phase != current.phase &&
                current.phase == ClassPaymentPhase.paid),
        listener: _onChange,
        builder: (context, state) {
          final checkout = state.checkout;
          return switch (state.phase) {
            ClassPaymentPhase.paid => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.pop(true);
              },
              child: PaymentSuccessPage(
                detail: detail,
                onProceed: () => context.pop(true),
              ),
            ),
            ClassPaymentPhase.checkout when checkout != null =>
              PaystackCheckoutView(
                key: ValueKey(checkout.reference),
                authorizationUrl: checkout.authorizationUrl,
                onFinished: ({required cancelled}) => unawaited(
                  context.read<ClassPaymentCubit>().checkoutClosed(
                    cancelled: cancelled,
                  ),
                ),
              ),
            _ => _PaymentSummary(detail: detail, state: state),
          };
        },
      ),
    );
  }

  void _onChange(BuildContext context, ClassPaymentState state) {
    if (state.phase == ClassPaymentPhase.paid) {
      AppHaptics.success();
      return;
    }
    final l10n = context.l10n;
    switch (state.issue) {
      case ClassPaymentIssue.notCompleted:
        AppSnackbar.warning(l10n.paymentNotCompleted);
      case ClassPaymentIssue.declined:
        AppHaptics.error();
        AppSnackbar.error(l10n.paymentDeclined);
      case ClassPaymentIssue.unconfirmed:
        AppSnackbar.warning(l10n.paymentUnconfirmed);
      case ClassPaymentIssue.failed:
        AppHaptics.error();
        AppSnackbar.error(state.message ?? l10n.paymentStartFailed);
      case null:
        break;
    }
  }
}

class _PaymentSummary extends StatelessWidget {
  const new({required this.detail, required this.state});

  final ClassDetail detail;
  final ClassPaymentState state;

  String _formatNaira(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final withCommas = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '₦$withCommas.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = detail.item;
    final total = _formatNaira(detail.source.effectivePrice);
    final verifying = state.phase == ClassPaymentPhase.verifying;
    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s24,
                  AppSpacing.s24,
                  0,
                ),
                child: Row(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s8),
                    Expanded(
                      child: Text(
                        l10n.paymentTitle,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        border: Border.all(
                          color: context.colors.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: context.textTheme.titleLarge),
                          const Gap(AppSpacing.s4),
                          Text(
                            item.instructor,
                            style: context.textTheme.bodyMedium,
                          ),
                          const Gap(AppSpacing.s4),
                          Text(
                            item.dateRange,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.s24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.paymentTotal,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          total,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.s24),
                    AppButton(
                      label: l10n.paymentPayButton(total),
                      isLoading: state.isBusy,
                      onPressed: () {
                        AppHaptics.selection();
                        unawaited(context.read<ClassPaymentCubit>().pay());
                      },
                    ),
                    if (verifying) ...[
                      const Gap(AppSpacing.s8),
                      Text(
                        l10n.paymentConfirming,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                    const Gap(AppSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const Gap(AppSpacing.s4),
                        Flexible(
                          child: Text(
                            l10n.paymentSecuredByPaystack,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
