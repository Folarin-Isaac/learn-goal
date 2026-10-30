import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_material_row.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_quiz_card.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';

class ClassDetailsPage extends StatelessWidget {
  const new({required this.lengoalClass, super.key});

  final LengoalClass lengoalClass;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ClassDetailBloc>(param1: lengoalClass)
            ..add(const ClassDetailRefreshRequested()),
      child: BlocBuilder<ClassDetailBloc, ClassDetailState>(
        buildWhen: (previous, current) =>
            previous.lengoalClass != current.lengoalClass,
        builder: (context, state) => _ClassDetailsView(
          detail: ClassDetail.fromClass(state.lengoalClass),
        ),
      ),
    );
  }
}

class _ClassDetailsView extends StatelessWidget {
  const new({required this.detail});

  final ClassDetail detail;

  @override
  Widget build(BuildContext context) {
    final isSubscribed = detail.item.isSubscribed;
    final tabs = [
      context.l10n.classDetailsTabAbout,
      context.l10n.classDetailsTabSchedule,
      if (isSubscribed) context.l10n.classDetailsTabQuiz,
      context.l10n.classDetailsTabMaterials,
      context.l10n.classDetailsTabCertificate,
    ];

    return DefaultTabController(
      length: tabs.length,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Entrance(
                      child: Row(
                        children: [
                          const AppBackButton(),
                          const Gap(AppSpacing.s8),
                          Expanded(
                            child: Text(
                              context.l10n.classDetailsTitle,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                    Entrance(index: 1, child: _DetailHeader(detail: detail)),
                    const Gap(AppSpacing.s8),
                  ],
                ),
              ),
              Entrance(
                index: 2,
                child: AppTabBar(labels: tabs, isScrollable: true),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _AboutTab(detail: detail),
                    _ScheduleTab(sessions: detail.sessions),
                    if (isSubscribed) _QuizTab(quizzes: detail.quizzes),
                    _MaterialsTab(materials: detail.materials),
                    _CertificateTab(hasCertificate: detail.hasCertificate),
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

class _DetailHeader extends StatelessWidget {
  const new({required this.detail});

  final ClassDetail detail;

  @override
  Widget build(BuildContext context) {
    final item = detail.item;
    final isFree = item.priceLabel == null;
    final tagBackground = isFree
        ? const Color(0xFFDAF2E4)
        : const Color(0xFFE0EBFF);
    final tagForeground = isFree
        ? const Color(0xFF0E8C43)
        : const Color(0xFF004DE6);
    final tagIcon = isFree
        ? Assets.icons.freeTagIcon
        : Assets.icons.premiumTagIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClassCover(item: item),
          ),
        ),
        const Gap(AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: Text(item.title, style: context.textTheme.headlineSmall),
            ),
            IconButton(
              onPressed: () {
                AppHaptics.selection();
                AppSnackbar.info(context.l10n.dashboardComingSoon);
              },
              icon: Assets.icons.shareIcon.svg(width: 20, height: 20),
            ),
          ],
        ),
        Text(item.dateRange, style: context.textTheme.bodyMedium),
        const Gap(AppSpacing.s4),
        Text(item.instructor, style: context.textTheme.bodyLarge),
        if (detail.reviewCount > 0) ...[
          const Gap(AppSpacing.s8),
          Row(
            children: [
              Text(
                detail.rating.toStringAsFixed(1),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFF2A93B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Assets.icons.starIcon.svg(width: 14, height: 14),
                ),
              const Gap(4),
              Text(
                context.l10n.classDetailsRatingCount(detail.reviewCount),
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        const Gap(AppSpacing.s8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: tagBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tagIcon.svg(width: 14, height: 14),
                  const Gap(4),
                  Text(
                    isFree ? context.l10n.dashboardFreeTag : item.priceLabel!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: tagForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!isFree) ...[
              const Gap(AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAF2E4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  context.l10n.classDetailsStatusPaid,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0E8C43),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!item.isSubscribed) ...[
          const Gap(AppSpacing.s16),
          AppButton(
            label: context.l10n.classDetailsBuyNow,
            onPressed: () {
              AppHaptics.selection();
              unawaited(context.pushNamed(RouteNames.payment, extra: detail));
            },
          ),
          const Gap(AppSpacing.s8),
          AppButton(
            label: context.l10n.classDetailsSaveClass,
            isOutlined: true,
            onPressed: () {
              AppHaptics.selection();
              AppSnackbar.info(context.l10n.dashboardComingSoon);
            },
          ),
        ],
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const new({required this.detail});

  final ClassDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.outline.isNotEmpty) ...[
            Text(
              context.l10n.classDetailsOutlineHeading,
              style: context.textTheme.titleLarge,
            ),
            const Gap(AppSpacing.s8),
            Text(detail.outline, style: context.textTheme.bodyMedium),
            const Gap(AppSpacing.s24),
          ],
          Text(
            context.l10n.classDetailsAboutInstructor(detail.item.instructor),
            style: context.textTheme.titleLarge,
          ),
          if (detail.instructorTitle.isNotEmpty) ...[
            const Gap(AppSpacing.s4),
            Text(detail.instructorTitle, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const new({required this.sessions});

  final List<CalendarSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsScheduleEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) {
        final session = sessions[index];
        if (session.status != CalendarSessionStatus.ongoing) {
          return CalendarSessionCard(session: session);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalendarSessionCard(session: session),
            const Gap(AppSpacing.s16),
            AppButton(
              label: context.l10n.classDetailsJoinUpcoming,
              onPressed: () {
                AppHaptics.selection();
                AppSnackbar.info(context.l10n.dashboardComingSoon);
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuizTab extends StatelessWidget {
  const new({required this.quizzes});

  final List<ClassQuiz> quizzes;

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsQuizEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) => ClassQuizCard(quiz: quizzes[index]),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const new({required this.materials});

  final List<ClassMaterial> materials;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsMaterialsEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.all(AppSpacing.s24),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Column(
          children: [
            for (var i = 0; i < materials.length; i++) ...[
              ClassMaterialRow(material: materials[i]),
              if (i != materials.length - 1)
                Divider(height: 1, color: context.colors.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _CertificateTab extends StatelessWidget {
  const new({required this.hasCertificate});

  final bool hasCertificate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasCertificate) ...[
            Text(
              context.l10n.classDetailsCertificateLocked,
              style: context.textTheme.titleLarge,
            ),
            const Gap(AppSpacing.s24),
          ] else ...[
            const _CertificatePreview(),
            const Gap(AppSpacing.s24),
          ],
          AppButton(
            label: context.l10n.classDetailsDownloadCertificate,
            isOutlined: true,
            onPressed: () {
              AppHaptics.selection();
              AppSnackbar.info(context.l10n.dashboardComingSoon);
            },
          ),
        ],
      ),
    );
  }
}

class _CertificatePreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CERTIFICATE',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Text(
              'OF ACHIEVEMENT',
              style: context.textTheme.bodySmall?.copyWith(letterSpacing: 2),
            ),
            const Gap(AppSpacing.s16),
            Icon(
              Icons.workspace_premium_rounded,
              color: context.colors.primary,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}
