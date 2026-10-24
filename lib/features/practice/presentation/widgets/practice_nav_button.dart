import 'package:lengoal/core/core.dart';

class PracticeNavButton extends StatelessWidget {
  const new({required this.isForward, required this.onPressed, super.key});

  final bool isForward;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final icon = isForward
        ? Assets.icons.practiceArrowRightIcon
        : Assets.icons.practiceArrowLeftIcon;

    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        onTap: isEnabled
            ? () {
                AppHaptics.selection();
                onPressed!();
              }
            : null,
        child: Container(
          width: 52,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            border: Border.all(
              color: isEnabled ? AppColors.accentBlue : AppColors.borderGray200,
            ),
          ),
          child: icon.svg(
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isEnabled ? AppColors.accentBlue : AppColors.borderGray200,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
