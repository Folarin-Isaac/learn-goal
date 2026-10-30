import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';

class PaymentPage extends StatefulWidget {
  const new({required this.detail, super.key});

  final ClassDetail detail;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _email = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _cardholderName = TextEditingController();
  final _country = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvc.dispose();
    _cardholderName.dispose();
    _country.dispose();
    _state.dispose();
    _zip.dispose();
    super.dispose();
  }

  double get _subtotal => widget.detail.source.effectivePrice;

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
    final subtotal = _subtotal;
    final vat = subtotal * 0.075;
    final total = subtotal + vat;

    return Scaffold(
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
                      context.l10n.paymentTitle,
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
                  AppTextField(
                    controller: _email,
                    label: context.l10n.paymentEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Gap(AppSpacing.s16),
                  AppTextField(
                    controller: _cardNumber,
                    label: context.l10n.paymentCardNumber,
                    keyboardType: TextInputType.number,
                    hint: '1234 1234 1234 1234',
                  ),
                  const Gap(AppSpacing.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _expiry,
                          label: context.l10n.paymentExpiry,
                          hint: 'MM/YY',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Gap(AppSpacing.s16),
                      Expanded(
                        child: AppTextField(
                          controller: _cvc,
                          label: context.l10n.paymentCvc,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.s16),
                  AppTextField(
                    controller: _cardholderName,
                    label: context.l10n.paymentCardholderName,
                  ),
                  const Gap(AppSpacing.s24),
                  Text(
                    context.l10n.paymentBillingAddress,
                    style: context.textTheme.titleLarge,
                  ),
                  const Gap(AppSpacing.s16),
                  AppTextField(
                    controller: _country,
                    label: context.l10n.paymentCountry,
                  ),
                  const Gap(AppSpacing.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _state,
                          label: context.l10n.paymentState,
                        ),
                      ),
                      const Gap(AppSpacing.s16),
                      Expanded(
                        child: AppTextField(
                          controller: _zip,
                          label: context.l10n.paymentZip,
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.s24),
                  _SummaryRow(
                    label: context.l10n.paymentSubtotal,
                    value: _formatNaira(subtotal),
                  ),
                  const Gap(AppSpacing.s8),
                  _SummaryRow(
                    label: context.l10n.paymentVat,
                    value: _formatNaira(vat),
                  ),
                  const Gap(AppSpacing.s8),
                  Divider(color: context.colors.outlineVariant),
                  const Gap(AppSpacing.s8),
                  _SummaryRow(
                    label: context.l10n.paymentTotal,
                    value: _formatNaira(total),
                    isTotal: true,
                  ),
                  const Gap(AppSpacing.s24),
                  AppButton(
                    label: context.l10n.paymentPayButton(_formatNaira(total)),
                    onPressed: () {
                      AppHaptics.selection();
                      context.pushReplacementNamed(
                        RouteNames.paymentSuccess,
                        extra: widget.detail,
                      );
                    },
                  ),
                  const Gap(AppSpacing.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const Gap(4),
                      Text(
                        context.l10n.paymentSecureNote,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const new({required this.label, required this.value, this.isTotal = false});

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        : context.textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
