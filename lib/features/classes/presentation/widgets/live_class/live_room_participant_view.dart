import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_controller.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveRoomParticipantView extends StatelessWidget {
  const new({
    required this.tile,
    required this.isLocal,
    required this.isEducator,
    this.large = false,
    super.key,
  });

  final LiveRoomTile tile;
  final bool isLocal;
  final bool isEducator;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final participant = tile.participant;
    final track = tile.track;
    final name = isLocal ? context.l10n.liveClassYou : _displayName;
    final highlight = participant.isSpeaking && !tile.isScreenShare;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: highlight ? AppColors.brandGreen : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (track != null)
            VideoTrackRenderer(
              track,
              key: ValueKey(track.sid),
              fit: large || tile.isScreenShare
                  ? VideoViewFit.contain
                  : VideoViewFit.cover,
            )
          else
            Center(
              child: _Initials(name: name, size: large ? 96 : 48),
            ),
          Positioned(
            left: AppSpacing.s8,
            bottom: AppSpacing.s8,
            right: AppSpacing.s8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _NameTag(
                name: name,
                muted: !tile.isScreenShare && participant.isMuted,
                isEducator: isEducator,
                isScreenShare: tile.isScreenShare,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final participant = tile.participant;
    final name = participant.name.trim();
    return name.isNotEmpty ? name : participant.identity;
  }
}

class _Initials extends StatelessWidget {
  const new({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first.toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style:
            (size > 64
                    ? context.textTheme.headlineMedium
                    : context.textTheme.titleMedium)
                ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _NameTag extends StatelessWidget {
  const new({
    required this.name,
    required this.muted,
    required this.isEducator,
    required this.isScreenShare,
  });

  final String name;
  final bool muted;
  final bool isEducator;
  final bool isScreenShare;

  @override
  Widget build(BuildContext context) {
    final label = isScreenShare ? context.l10n.liveClassPresenting(name) : name;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppSpacing.r4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (muted) ...[
            const Icon(Icons.mic_off, size: 14, color: Colors.white),
            const Gap(AppSpacing.s4),
          ],
          if (isEducator && !isScreenShare) ...[
            const Icon(Icons.school_outlined, size: 14, color: Colors.white),
            const Gap(AppSpacing.s4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
