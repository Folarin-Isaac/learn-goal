import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';

class LoginPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        loginUseCase: getIt<LoginUseCase>(),
        resendOtpUseCase: getIt<ResendOtpUseCase>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const new();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.failure) {
            AppHaptics.error();
            AppSnackbar.error(state.errorMessage ?? context.l10n.errorGeneric);
          }
          if (state.status == LoginStatus.emailNotConfirmed) {
            AppHaptics.selection();
            AppSnackbar.info(context.l10n.loginEmailNotConfirmed);
            context.pushNamed(RouteNames.otpVerify, extra: state.email);
          }
          if (state.status == LoginStatus.success) {
            AppHaptics.success();
            AppSnackbar.success(context.l10n.loginSuccessMessage);
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == LoginStatus.submitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(AppSpacing.s24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        radius: 28,
                        child: Assets.images.logo.image(width: 32, height: 32),
                      ),
                    ),
                    const Gap(AppSpacing.s24),
                    Text(
                      context.l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(AppSpacing.s4),
                    Text(
                      context.l10n.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(AppSpacing.s32),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.loginEmailLabel,
                      hint: context.l10n.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.email(context, value),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _passwordController,
                      label: context.l10n.loginPasswordLabel,
                      hint: context.l10n.loginPasswordHint,
                      textInputAction: TextInputAction.done,
                      isPassword: true,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isSubmitting,
                      validator: (value) => Validators.password(context, value),
                    ),
                    const Gap(AppSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                          onTap: isSubmitting
                              ? null
                              : () {
                                  AppHaptics.selection();
                                  context.read<LoginBloc>().add(
                                    LoginKeepSignedInToggled(
                                      !state.keepSignedIn,
                                    ),
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Checkbox(
                                      value: state.keepSignedIn,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) {
                                              AppHaptics.selection();
                                              context.read<LoginBloc>().add(
                                                LoginKeepSignedInToggled(
                                                  value ?? false,
                                                ),
                                              );
                                            },
                                    ),
                                  ),
                                ),
                                const Gap(AppSpacing.s4),
                                Text(
                                  context.l10n.loginKeepSignedIn,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.unfocus();
                            AppHaptics.selection();
                            context.pushNamed(RouteNames.forgotPassword);
                          },
                          child: Text(
                            context.l10n.loginForgotPassword,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.s32),
                    AppButton(
                      label: context.l10n.loginSubmit,
                      icon: const Icon(Icons.login, size: 18),
                      isLoading: state.status == LoginStatus.submitting,
                      onPressed: () => _submit(context),
                    ),
                    // const Gap(AppSpacing.s16),
                    // GoogleSignInButton(onPressed: () {}),
                    const Gap(AppSpacing.s24),
                    Center(
                      child: Wrap(
                        children: [
                          Text(
                            '${context.l10n.loginNoAccount} ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.unfocus();
                              AppHaptics.selection();
                              context.pushNamed(RouteNames.register);
                            },
                            child: Text(
                              context.l10n.loginSignUpLink,
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
    context.read<LoginBloc>()
      ..add(LoginEmailChanged(_emailController.text.trim()))
      ..add(LoginPasswordChanged(_passwordController.text));

    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(const LoginSubmitted());
    } else {
      AppHaptics.error();
    }
  }
}
