import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class ChangePasswordPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordBloc>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const new();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    final error = Validators.strongPassword(context, value);
    if (error != null) return error;
    if (value == _currentController.text) {
      return context.l10n.changePasswordSameAsCurrent;
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppHaptics.error();
      return;
    }
    AppHaptics.selection();
    context.unfocus();
    context.read<ChangePasswordBloc>().add(
      ChangePasswordSubmitted(
        oldPassword: _currentController.text,
        newPassword: _newController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
          listener: (context, state) {
            if (state.status == ChangePasswordStatus.failure) {
              AppHaptics.error();
              AppSnackbar.error(
                state.errorMessage ?? context.l10n.errorGeneric,
              );
            }
            if (state.status == ChangePasswordStatus.success) {
              AppHaptics.success();
              AppSnackbar.success(context.l10n.changePasswordSuccess);
              context.pop();
            }
          },
          builder: (context, state) {
            final isSubmitting = state.isSubmitting;
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                            context.l10n.profileUpdatePassword,
                            style: context.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.s8),
                    Text(
                      context.l10n.changePasswordSubtitle,
                      style: context.textTheme.bodyMedium,
                    ),
                    const Gap(AppSpacing.s24),
                    AppTextField(
                      controller: _currentController,
                      label: context.l10n.changePasswordCurrentLabel,
                      hint: context.l10n.changePasswordCurrentHint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.notEmpty(
                        context,
                        value,
                        context.l10n.changePasswordCurrentLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _newController,
                      label: context.l10n.changePasswordNewLabel,
                      hint: context.l10n.changePasswordNewHint,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !isSubmitting,
                      validator: _validateNewPassword,
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _confirmController,
                      label: context.l10n.changePasswordConfirmLabel,
                      hint: context.l10n.changePasswordConfirmHint,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.confirmPassword(
                        context,
                        value,
                        _newController.text,
                        fieldLabel: context.l10n.changePasswordConfirmLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s32),
                    AppButton(
                      label: context.l10n.profileSaveButton,
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
