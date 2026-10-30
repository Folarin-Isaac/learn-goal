import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class RegisterPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(registerUseCase: getIt<RegisterUseCase>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const new();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
          if (state.status == RegisterStatus.success) {
            AppHaptics.success();
            AppSnackbar.success(context.l10n.registerSuccessMessage);
            unawaited(
              context.pushNamed(RouteNames.otpVerify, extra: state.email),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == RegisterStatus.submitting;
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
                      context.l10n.registerTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      context.l10n.registerSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(AppSpacing.s32),
                    AppTextField(
                      controller: _firstNameController,
                      label: context.l10n.registerFirstNameLabel,
                      hint: context.l10n.registerFirstNameHint,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.givenName],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.notEmpty(
                        context,
                        value,
                        context.l10n.registerFirstNameLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _lastNameController,
                      label: context.l10n.registerLastNameLabel,
                      hint: context.l10n.registerLastNameHint,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.familyName],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.notEmpty(
                        context,
                        value,
                        context.l10n.registerLastNameLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.registerEmailLabel,
                      hint: context.l10n.registerEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.email(context, value),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _phoneController,
                      label: context.l10n.registerPhoneLabel,
                      hint: context.l10n.registerPhoneHint,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      enabled: !isSubmitting,
                      validator: (value) =>
                          Validators.phoneNumber(context, value),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _passwordController,
                      label: context.l10n.registerPasswordLabel,
                      hint: context.l10n.registerPasswordHint,
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
                      label: context.l10n.registerConfirmPasswordLabel,
                      hint: context.l10n.registerConfirmPasswordHint,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.confirmPassword(
                        context,
                        value,
                        _passwordController.text,
                        fieldLabel: context.l10n.registerConfirmPasswordLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s48),
                    AppButton(
                      label: context.l10n.registerSubmit,
                      isLoading: state.status == RegisterStatus.submitting,
                      onPressed: () => _submit(context),
                    ),
                    const Gap(AppSpacing.s16),
                    GoogleSignInButton(onPressed: () {}),
                    const Gap(AppSpacing.s16),
                    Center(
                      child: Wrap(
                        children: [
                          Text(
                            '${context.l10n.registerHaveAccount} ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.unfocus();
                              AppHaptics.selection();
                              context.pop();
                            },
                            child: Text(
                              context.l10n.registerSignInLink,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
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
    context.read<RegisterBloc>()
      ..add(RegisterFirstNameChanged(_firstNameController.text.trim()))
      ..add(RegisterLastNameChanged(_lastNameController.text.trim()))
      ..add(RegisterEmailChanged(_emailController.text.trim()))
      ..add(RegisterPhoneNumberChanged(_phoneController.text.trim()))
      ..add(RegisterPasswordChanged(_passwordController.text))
      ..add(RegisterConfirmPasswordChanged(_confirmController.text));

    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterBloc>().add(const RegisterSubmitted());
    } else {
      AppHaptics.error();
    }
  }
}
