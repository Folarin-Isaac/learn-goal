import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_class_closed_view.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_class_lobby.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_class_room.dart';

class LiveClassPage extends StatelessWidget {
  const new({required this.session, super.key});

  final LiveClassSession session;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<LiveClassCubit>(param1: session.sessionId);
        unawaited(cubit.loadStatus());
        return cubit;
      },
      child: BlocConsumer<LiveClassCubit, LiveClassState>(
        listenWhen: (previous, current) =>
            previous.errorCount != current.errorCount,
        listener: (context, state) {
          final error = state.error;
          if (error == null) return;
          AppHaptics.error();
          AppSnackbar.error(error);
        },
        buildWhen: (previous, current) =>
            previous.phase != current.phase ||
            previous.access != current.access ||
            previous.status != current.status ||
            previous.micOn != current.micOn ||
            previous.cameraOn != current.cameraOn,
        builder: (context, state) {
          final access = state.access;
          return switch (state.phase) {
            LiveClassPhase.inRoom when access != null => LiveClassRoom(
              key: ValueKey(access.token),
              session: session,
              access: access,
              joinWithMic: state.micOn,
              joinWithCamera: state.cameraOn,
            ),
            LiveClassPhase.ended ||
            LiveClassPhase.dropped ||
            LiveClassPhase.replaced ||
            LiveClassPhase.removed => LiveClassClosedView(
              session: session,
              phase: state.phase,
            ),
            _ => LiveClassLobby(
              session: session,
              status: state.status,
              micOn: state.micOn,
              cameraOn: state.cameraOn,
              isJoining: state.phase == LiveClassPhase.joining,
            ),
          };
        },
      ),
    );
  }
}
