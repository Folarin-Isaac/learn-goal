import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_about_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_certificate_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_detail_header.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_materials_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_quiz_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_schedule_tab.dart';
import 'package:share_plus/share_plus.dart';

class ClassDetailsPage extends StatelessWidget {
  const new({required this.lengoalClass, super.key});

  final LengoalClass lengoalClass;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ClassDetailBloc>(param1: lengoalClass)
            ..add(const ClassDetailRefreshRequested()),
      child: BlocConsumer<ClassDetailBloc, ClassDetailState>(
        listenWhen: (previous, current) =>
            previous.effectCount != current.effectCount,
        listener: _onEffect,
        buildWhen: (previous, current) =>
            previous.lengoalClass != current.lengoalClass ||
            previous.educators != current.educators ||
            previous.isSharing != current.isSharing ||
            previous.loadingReplayId != current.loadingReplayId,
        builder: (context, state) => _ClassDetailsView(
          detail: ClassDetail.fromClass(state.lengoalClass),
          educators: state.educators,
          isSharing: state.isSharing,
          loadingReplayId: state.loadingReplayId,
        ),
      ),
    );
  }

  Future<void> _onEffect(BuildContext context, ClassDetailState state) async {
    final effect = state.effect;
    if (effect == null) return;
    final l10n = context.l10n;
    switch (effect.kind) {
      case ClassDetailEffectKind.share:
        await SharePlus.instance.share(
          ShareParams(
            text: l10n.classDetailsShareText(
              state.lengoalClass.cohortName,
              effect.value,
            ),
          ),
        );
      case ClassDetailEffectKind.open:
        if (!await openExternalUrl(effect.value)) {
          AppSnackbar.error(l10n.classDetailsLinkOpenFailed);
        }
      case ClassDetailEffectKind.error:
        AppHaptics.error();
        AppSnackbar.error(effect.value);
    }
  }
}

class _ClassDetailsView extends StatelessWidget {
  const new({
    required this.detail,
    required this.educators,
    required this.isSharing,
    required this.loadingReplayId,
  });

  final ClassDetail detail;
  final List<ClassEducator> educators;
  final bool isSharing;
  final String? loadingReplayId;

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
                    Entrance(
                      index: 1,
                      child: ClassDetailHeader(
                        detail: detail,
                        isSharing: isSharing,
                      ),
                    ),
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
                    ClassAboutTab(detail: detail, educators: educators),
                    ClassScheduleTab(
                      sessions: detail.sessions,
                      loadingReplayId: loadingReplayId,
                      isSubscribed: isSubscribed,
                    ),
                    if (isSubscribed) ClassQuizTab(quizzes: detail.quizzes),
                    ClassMaterialsTab(materials: detail.materials),
                    ClassCertificateTab(hasCertificate: detail.hasCertificate),
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
