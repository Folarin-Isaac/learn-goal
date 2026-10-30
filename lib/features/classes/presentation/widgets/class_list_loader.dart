import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';

class ClassListLoader extends StatelessWidget {
  const new({
    required this.source,
    required this.loading,
    required this.builder,
    this.compactError = false,
    super.key,
  });

  final ClassListSource source;
  final Widget loading;
  final Widget Function(BuildContext context, List<LengoalClass> classes)
  builder;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ClassListBloc>(param1: source)..add(const ClassListRequested()),
      child: BlocBuilder<ClassListBloc, ClassListState>(
        builder: (context, state) {
          if (state.isLoading) return loading;
          if (state.status == ClassListStatus.failure) {
            return _ClassListError(
              message: state.errorMessage ?? context.l10n.errorGeneric,
              compact: compactError,
              onRetry: () {
                AppHaptics.selection();
                context.read<ClassListBloc>().add(const ClassListRequested());
              },
            );
          }
          return builder(context, state.classes);
        },
      ),
    );
  }
}

class _ClassListError extends StatelessWidget {
  const new({
    required this.message,
    required this.compact,
    required this.onRetry,
  });

  final String message;
  final bool compact;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!compact) {
      return ErrorView(
        message: message,
        onRetry: onRetry,
        retryLabel: context.l10n.commonRetry,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
        ],
      ),
    );
  }
}

class ClassTileListSkeleton extends StatelessWidget {
  const new({this.padding = EdgeInsets.zero, super.key});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
        itemBuilder: (context, index) => const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 120, radius: AppSpacing.r12),
            Gap(AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(AppSpacing.s8),
                  SkeletonBox(width: 90),
                  Gap(AppSpacing.s8),
                  SkeletonBox(height: 16),
                  Gap(AppSpacing.s8),
                  SkeletonBox(width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassCardRowSkeleton extends StatelessWidget {
  const new({required this.cardWidth, super.key});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const Gap(AppSpacing.s16),
              SizedBox(
                width: cardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: cardWidth,
                      height: cardWidth / 1.35,
                      radius: AppSpacing.r12,
                    ),
                    const Gap(AppSpacing.s8),
                    const SkeletonBox(width: 70),
                    const Gap(AppSpacing.s8),
                    const SkeletonBox(height: 16),
                    const Gap(AppSpacing.s8),
                    const SkeletonBox(width: 90),
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
