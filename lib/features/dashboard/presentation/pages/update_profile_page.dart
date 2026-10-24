import 'package:image_picker/image_picker.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/profile/profile.dart';

class UpdateProfilePage extends StatelessWidget {
  const new({required this.profile, super.key});

  final LearnerProfile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<UpdateProfileBloc>()..add(const UpdateProfileStarted()),
      child: _UpdateProfileView(profile: profile),
    );
  }
}

class _UpdateProfileView extends StatefulWidget {
  const new({required this.profile});

  final LearnerProfile profile;

  @override
  State<_UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<_UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late final _firstNameController = TextEditingController(
    text: widget.profile.firstName,
  );
  late final _lastNameController = TextEditingController(
    text: widget.profile.lastName,
  );
  late final _phoneController = TextEditingController(
    text: widget.profile.phoneNumber ?? '',
  );
  final _picker = ImagePicker();

  late String _baselineFirstName = widget.profile.firstName;
  late String _baselineLastName = widget.profile.lastName;
  late String _baselinePhone = widget.profile.phoneNumber ?? '';
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _phoneController,
    ]) {
      controller.addListener(_recomputeDirty);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Compared against the loaded values rather than tracking "has typed",
  // so editing a field and undoing it disables Save again.
  void _recomputeDirty({String? pickedAvatarUrl}) {
    final hasAvatarChange =
        pickedAvatarUrl != null ||
        context.read<UpdateProfileBloc>().state.uploadedAvatarUrl != null;
    final dirty =
        hasAvatarChange ||
        _firstNameController.text.trim() != _baselineFirstName.trim() ||
        _lastNameController.text.trim() != _baselineLastName.trim() ||
        _phoneController.text.trim() != _baselinePhone.trim();
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  // Overwrites the seeded values once the fetched profile differs from
  // what was passed in, and re-baselines so Save stays disabled.
  void _applyLoadedProfile(LearnerProfile profile) {
    _baselineFirstName = profile.firstName;
    _baselineLastName = profile.lastName;
    _baselinePhone = profile.phoneNumber ?? '';
    _emailController.text = profile.email;
    if (_firstNameController.text == widget.profile.firstName) {
      _firstNameController.text = profile.firstName;
    }
    if (_lastNameController.text == widget.profile.lastName) {
      _lastNameController.text = profile.lastName;
    }
    if (_phoneController.text == (widget.profile.phoneNumber ?? '')) {
      _phoneController.text = profile.phoneNumber ?? '';
    }
    _recomputeDirty();
  }

  Future<void> _pickAvatar() async {
    AppHaptics.selection();
    final source = await AvatarSourceSheet.show(context);
    if (source == null || !mounted) return;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    context.read<UpdateProfileBloc>().add(
      UpdateProfileAvatarPicked(picked.path),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppHaptics.selection();
    context.unfocus();
    context.read<UpdateProfileBloc>().add(
      UpdateProfileSubmitted(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
          listener: (context, state) {
            if (state.loadStatus == ProfileLoadStatus.loaded &&
                state.profile != null) {
              _applyLoadedProfile(state.profile!);
            }
            if (state.uploadedAvatarUrl != null) {
              _recomputeDirty(pickedAvatarUrl: state.uploadedAvatarUrl);
            }
            if (state.saveStatus == ProfileSaveStatus.failure ||
                state.loadStatus == ProfileLoadStatus.failure) {
              AppHaptics.error();
              AppSnackbar.error(
                state.errorMessage ?? context.l10n.errorGeneric,
              );
            }
            if (state.saveStatus == ProfileSaveStatus.success) {
              AppHaptics.success();
              AppSnackbar.success(context.l10n.profileUpdateSuccess);
              context.pop();
            }
          },
          builder: (context, state) {
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
                            context.l10n.profileUpdateProfileTitle,
                            style: context.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.s24),
                    Center(
                      child: ProfileAvatar(
                        localPath: state.pendingAvatarPath,
                        imageUrl: state.effectiveAvatarUrl,
                        isBusy: state.saveStatus == ProfileSaveStatus.uploading,
                        onEdit: _pickAvatar,
                      ),
                    ),
                    const Gap(AppSpacing.s24),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.loginEmailLabel,
                      hint: context.l10n.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _firstNameController,
                      label: context.l10n.registerFirstNameLabel,
                      hint: context.l10n.registerFirstNameHint,
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
                      validator: (value) => Validators.notEmpty(
                        context,
                        value,
                        context.l10n.registerLastNameLabel,
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    AppTextField(
                      controller: _phoneController,
                      label: context.l10n.registerPhoneLabel,
                      hint: context.l10n.registerPhoneHint,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          Validators.phoneNumber(context, value),
                    ),
                    const Gap(AppSpacing.s24),
                    AppButton(
                      label: context.l10n.profileSaveButton,
                      isLoading: state.saveStatus == ProfileSaveStatus.saving,
                      onPressed: (!_isDirty || state.isBusy) ? null : _save,
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
