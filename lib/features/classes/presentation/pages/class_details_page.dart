import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_discussion/class_discussion_cubit.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_about_tab.dart';
// import 'package:lengoal/features/classes/presentation/widgets/class_details/class_certificate_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_communications_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_detail_header.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_materials_tab.dart';
// import 'package:lengoal/features/classes/presentation/widgets/class_details/class_quiz_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_schedule_tab.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:share_plus/share_plus.dart';

class ClassDetailsPage extends StatefulWidget {
  const new({required this.lengoalClass, super.key});

  final LengoalClass lengoalClass;

  @override
  State<ClassDetailsPage> createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  final GlobalKey<NestedScrollViewState> _scrollKey = GlobalKey();

  LengoalClass get lengoalClass => widget.lengoalClass;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ClassDetailBloc>(param1: lengoalClass)
                ..add(const ClassDetailRefreshRequested()),
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<ClassDiscussionCubit>(param1: lengoalClass.id);
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: BlocConsumer<ClassDetailBloc, ClassDetailState>(
        listenWhen: (previous, current) =>
            previous.effectCount != current.effectCount,
        listener: _onEffect,
        buildWhen: (previous, current) =>
            previous.lengoalClass != current.lengoalClass ||
            previous.educators != current.educators ||
            previous.isSharing != current.isSharing ||
            previous.isEnrolling != current.isEnrolling ||
            previous.loadingReplayId != current.loadingReplayId ||
            previous.activeReplay != current.activeReplay ||
            previous.autoPlayReplay != current.autoPlayReplay,
        builder: (context, state) => _ClassDetailsView(
          detail: ClassDetail.fromClass(state.lengoalClass),
          educators: state.educators,
          isSharing: state.isSharing,
          isEnrolling: state.isEnrolling,
          loadingReplayId: state.loadingReplayId,
          activeReplay: state.activeReplay,
          autoPlayReplay: state.autoPlayReplay,
          scrollKey: _scrollKey,
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
      case ClassDetailEffectKind.enrolled:
        AppHaptics.success();
        AppSnackbar.success(l10n.classDetailsEnrolledMessage);
        unawaited(
          refreshClassLists(const [
            ClassListSource.subscribed,
            ClassListSource.goalSubscribed,
            ClassListSource.recommended,
            ClassListSource.saved,
          ]),
        );
      case ClassDetailEffectKind.showReplay:
        final outer = _scrollKey.currentState?.outerController;
        if (outer != null && outer.hasClients && outer.offset > 0) {
          await outer.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
    }
  }
}

class _ClassDetailsView extends StatelessWidget {
  const new({
    required this.detail,
    required this.educators,
    required this.isSharing,
    required this.isEnrolling,
    required this.loadingReplayId,
    required this.activeReplay,
    required this.autoPlayReplay,
    required this.scrollKey,
  });

  final ClassDetail detail;
  final List<ClassEducator> educators;
  final bool isSharing;
  final bool isEnrolling;
  final String? loadingReplayId;
  final ClassReplay? activeReplay;
  final bool autoPlayReplay;
  final GlobalKey<NestedScrollViewState> scrollKey;

  @override
  Widget build(BuildContext context) {
    final isSubscribed = detail.item.isSubscribed;
    final tabs = [
      context.l10n.classDetailsTabOverview,
      context.l10n.classDetailsTabCommunications,
      context.l10n.classDetailsTabMaterials,
      context.l10n.classDetailsTabSchedule,
      // if (isSubscribed) context.l10n.classDetailsTabQuiz,
      // context.l10n.classDetailsTabCertificate,
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            key: scrollKey,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s24,
                    AppSpacing.s24,
                    AppSpacing.s8,
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
                          isEnrolling: isEnrolling,
                          activeReplay: activeReplay,
                          autoPlayReplay: autoPlayReplay,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeader(labels: tabs),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                ClassAboutTab(detail: detail, educators: educators),
                ClassCommunicationsTab(isSubscribed: isSubscribed),
                ClassMaterialsTab(materials: detail.materials),
                ClassScheduleTab(
                  lengoalClass: detail.source,
                  sessions: detail.sessions,
                  loadingReplayId: loadingReplayId,
                  isSubscribed: isSubscribed,
                ),
                // if (isSubscribed) ClassQuizTab(quizzes: detail.quizzes),
                // ClassCertificateTab(
                //   hasCertificate: detail.hasCertificate,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarHeader extends SliverPersistentHeaderDelegate {
  const new({required this.labels});

  final List<String> labels;

  static final double _height = const AppTabBar(labels: [])
      .preferredSize
      .height;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Entrance(
        index: 2,
        child: AppTabBar(labels: labels, isScrollable: true),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarHeader oldDelegate) =>
      !listEquals(labels, oldDelegate.labels);
}
