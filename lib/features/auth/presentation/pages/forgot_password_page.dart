import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class ForgotPasswordPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(
        forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
      ),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const new();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state.status == ForgotPasswordStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
          if (state.status == ForgotPasswordStatus.success) {
            AppHaptics.success();
            context.pushNamed(
              RouteNames.resetPasswordSent,
              extra: (email: state.email, token: state.resetToken),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == ForgotPasswordStatus.submitting;
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
                      context.l10n.forgotPasswordTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      context.l10n.forgotPasswordSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(AppSpacing.s32),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.forgotPasswordEmailLabel,
                      hint: context.l10n.forgotPasswordEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.email(context, value),
                    ),
                    const Gap(AppSpacing.s48 * 4),
                    AppButton(
                      label: context.l10n.forgotPasswordSubmit,
                      isLoading:
                          state.status == ForgotPasswordStatus.submitting,
                      onPressed: () => _submit(context),
                    ),
                    const Gap(AppSpacing.s16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.unfocus();
                          AppHaptics.selection();
                          context.pop();
                        },
                        child: Text(
                          context.l10n.forgotPasswordBackToLogin,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
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
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEmailChanged(_emailController.text.trim()),
    );

    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordBloc>().add(const ForgotPasswordSubmitted());
    } else {
      AppHaptics.error();
    }
  }
}
