import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class ResetPasswordPage extends StatelessWidget {
  const new({required this.email, required this.token, super.key});

  final String email;
  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordBloc(
        email: email,
        token: token,
        resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      ),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const new();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
        listener: (context, state) {
          if (state.status == ResetPasswordStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
          if (state.status == ResetPasswordStatus.success) {
            AppHaptics.success();
            context.pushReplacementNamed(RouteNames.resetPasswordSuccess);
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == ResetPasswordStatus.submitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(AppSpacing.s24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(),
                    ),
                    const Gap(AppSpacing.s24),
                    Text(
                      context.l10n.resetPasswordTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      context.l10n.resetPasswordSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(AppSpacing.s32),
                    AppTextField(
                      controller: _passwordController,
                      label: context.l10n.resetPasswordLabel,
                      hint: context.l10n.resetPasswordHint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !isSubmitting,
                      validator: (value) =>
                          Validators.strongPassword(context, value),
                      onChanged: (_) => setState(() {}),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _confirmController,
                      label: context.l10n.resetPasswordConfirmLabel,
                      hint: context.l10n.resetPasswordConfirmHint,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.confirmPassword(
                        context,
                        value,
                        _passwordController.text,
                        fieldLabel: context.l10n.resetPasswordConfirmLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s48 * 1.5),
                    AppButton(
                      label: context.l10n.resetPasswordSubmit,
                      isLoading: state.status == ResetPasswordStatus.submitting,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<ResetPasswordBloc>()
      ..add(ResetPasswordChanged(_passwordController.text))
      ..add(ResetPasswordConfirmChanged(_confirmController.text));

    if (_formKey.currentState?.validate() ?? false) {
      context.read<ResetPasswordBloc>().add(const ResetPasswordSubmitted());
    } else {
      AppHaptics.error();
    }
  }
}
