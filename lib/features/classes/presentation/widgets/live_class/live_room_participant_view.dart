import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_controller.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveRoomParticipantView extends StatelessWidget {
  const new({
    required this.tile,
    required this.isLocal,
    required this.isEducator,
    this.large = false,
    this.handRaised = false,
    this.expanded = false,
    this.onToggleExpand,
    this.bare = false,
    super.key,
  });

  final LiveRoomTile tile;
  final bool isLocal;
  final bool isEducator;
  final bool large;
  final bool handRaised;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final participant = tile.participant;
    final track = tile.track;
    final name = isLocal ? context.l10n.liveClassYou : _displayName;
    final highlight = participant.isSpeaking && !tile.isScreenShare;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: bare
          ? const BoxDecoration(color: Colors.black)
          : BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              border: Border.all(
                color: handRaised && !tile.isScreenShare
                    ? const Color(0xFFF59E0B)
                    : highlight
                    ? AppColors.brandGreen
                    : Colors.transparent,
                width: 2,
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (track != null && large && tile.isScreenShare)
            LiveZoomable(
              key: ValueKey(track.sid),
              child: VideoTrackRenderer(track),
            )
          else if (track != null)
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
          if (!bare)
            Positioned(
              left: AppSpacing.s8,
              bottom: AppSpacing.s8,
              right: onToggleExpand == null ? AppSpacing.s8 : 52,
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
          if (handRaised && !tile.isScreenShare)
            Positioned(
              top: AppSpacing.s8,
              right: AppSpacing.s8,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: Text('✋', style: TextStyle(fontSize: large ? 20 : 14)),
              ),
            ),
          if (onToggleExpand != null)
            Positioned(
              right: AppSpacing.s4,
              bottom: 0,
              child: Tooltip(
                message: expanded
                    ? context.l10n.liveClassExitFullScreen
                    : context.l10n.liveClassFullScreen,
                child: Semantics(
                  button: true,
                  label: expanded
                      ? context.l10n.liveClassExitFullScreen
                      : context.l10n.liveClassFullScreen,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleExpand,
                    child: SizedBox.square(
                      dimension: 44,
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            expanded ? Icons.fullscreen_exit : Icons.fullscreen,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
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

class LiveZoomable extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  State<LiveZoomable> createState() => _LiveZoomableState();
}

class _LiveZoomableState extends State<LiveZoomable>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _reset = AnimationController(
    vsync: this,
    duration: AppMotion.fast,
  );
  Animation<Matrix4>? _resetAnimation;

  static const double _maxScale = 4;

  @override
  void initState() {
    super.initState();
    _reset.addListener(() {
      final animation = _resetAnimation;
      if (animation != null) _transform.value = animation.value;
    });
  }

  @override
  void dispose() {
    _reset.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _resetZoom() {
    if (_transform.value.isIdentity()) return;
    AppHaptics.selection();
    _resetAnimation = Matrix4Tween(
      begin: _transform.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _reset, curve: Curves.easeOut));
    _reset.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _resetZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        maxScale: _maxScale,
        onInteractionStart: (_) => _reset.stop(),
        child: SizedBox.expand(child: widget.child),
      ),
    );
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
