import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_read/chat_read_store.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class ClassChatButton extends StatelessWidget {
  const new({required this.lengoalClass, super.key});

  final LengoalClass lengoalClass;

  void _open(BuildContext context) {
    AppHaptics.selection();
    final wentBack = context.popIfPrevious(
      RouteNames.chatThread,
      sameTarget: (extra) =>
          extra is LengoalClass && extra.id == lengoalClass.id,
    );
    if (wentBack) return;
    unawaited(context.pushNamed(RouteNames.chatThread, extra: lengoalClass));
  }

  @override
  Widget build(BuildContext context) {
    final icon = Assets.icons.chatsIcon.svg(
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
    );
    return IconButton(
      tooltip: context.l10n.chatsOpenClassChat,
      onPressed: () => _open(context),
      icon: ValueListenableBuilder<Set<String>>(
        valueListenable: getIt<ChatReadStore>().unread,
        builder: (context, unread, _) {
          if (!unread.contains(lengoalClass.id)) return icon;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              icon,
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
