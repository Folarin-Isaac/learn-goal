import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_controller.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_people.dart';
import 'package:livekit_client/livekit_client.dart';

class LivePeopleSheet extends StatefulWidget {
  const new({required this.controller, super.key});

  final LiveRoomController controller;

  static Future<void> show(
    BuildContext context,
    LiveRoomController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: LivePeopleSheet(controller: controller),
      ),
    );
  }

  static const Color _panel = Color(0xFA111111);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberText = Color(0xFFFBBF24);
  static const Color _you = Color(0xFF6366F1);
  static const Color _presenting = Color(0xFF818CF8);
  static const Color _speaking = Color(0xFF22C55E);
  static const Color _speakingText = Color(0xFF4ADE80);
  static const Color _muted = Color(0xFFF87171);
  static const List<Color> _avatarColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF97316),
  ];

  @override
  State<LivePeopleSheet> createState() => _LivePeopleSheetState();
}

class _LivePeopleSheetState extends State<LivePeopleSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, controller.room]),
      builder: (context, _) => ListenableBuilder(
        listenable: Listenable.merge(controller.participants),
        builder: (context, _) => _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = context.l10n;
    final people = widget.controller.people;
    final groups = groupPeople(people, _query);
    final hands = people.where((p) => p.isHandRaised).length;
    final anyPresentingOrSpeaking = groups.any(
      (g) =>
          g.section == LivePeopleSection.presenting ||
          g.section == LivePeopleSection.speaking,
    );
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const Gap(AppSpacing.s8),
                Text(
                  l10n.liveClassParticipants,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    '${people.length}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.liveClassClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s16,
              AppSpacing.s8,
            ),
            child: TextField(
              autofillHints: null,
              onChanged: (value) => setState(() => _query = value),
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.liveClassSearchParticipants,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white38,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ),
          if (hands > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s4,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: LivePeopleSheet._amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.r12),
                border: Border.all(
                  color: LivePeopleSheet._amber.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Text('✋', style: TextStyle(fontSize: 18)),
                  const Gap(AppSpacing.s8),
                  Text(
                    l10n.liveClassHandsRaised(hands),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: LivePeopleSheet._amberText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: groups.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s32),
                    child: Text(
                      l10n.liveClassNoParticipants,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white30,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                    children: [
                      for (final group in groups) ...[
                        _SectionLabel(
                          _sectionLabel(
                            context,
                            group,
                            anyPresentingOrSpeaking,
                          ),
                        ),
                        for (final person in group.people)
                          _PersonRow(person: person),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(
    BuildContext context,
    LivePeopleGroup group,
    bool anyPresentingOrSpeaking,
  ) {
    final l10n = context.l10n;
    return switch (group.section) {
      LivePeopleSection.raisedHands => l10n.liveClassSectionRaisedHands(
        group.people.length,
      ),
      LivePeopleSection.presenting => l10n.liveClassSectionPresenting,
      LivePeopleSection.speaking => l10n.liveClassSectionSpeaking,
      LivePeopleSection.rest =>
        anyPresentingOrSpeaking
            ? l10n.liveClassSectionOthers
            : l10n.liveClassSectionAll,
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s4,
      ),
      child: Text(
        text.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: Colors.white30,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const new({required this.person});

  final LivePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = context.textTheme.labelSmall;
    final quality = _qualityLabel(context, person.quality);
    final status = <Widget>[
      if (quality != null) ...[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _qualityColor(person.quality),
            shape: BoxShape.circle,
          ),
        ),
        const Gap(AppSpacing.s4),
        Text(quality, style: small?.copyWith(color: Colors.white38)),
      ],
      if (person.isPresenting) ...[
        if (quality != null) _dot(),
        Text(
          l10n.liveClassSectionPresenting,
          style: small?.copyWith(
            color: LivePeopleSheet._presenting,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      if (person.isSpeaking) ...[
        if (quality != null || person.isPresenting) _dot(),
        Text(
          l10n.liveClassSectionSpeaking,
          style: small?.copyWith(
            color: LivePeopleSheet._speakingText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          _Avatar(person: person),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (person.isLocal)
                      _Tag(l10n.liveClassYou, LivePeopleSheet._you),
                    if (person.isHost)
                      _Tag(l10n.liveClassTagHost, LivePeopleSheet._amber),
                    if (person.isHandRaised)
                      _Tag(l10n.liveClassTagRaised, LivePeopleSheet._amber),
                  ],
                ),
                if (status.isNotEmpty) ...[
                  const Gap(2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: status,
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.s8),
          if (person.isPresenting) ...[
            Tooltip(
              message: l10n.liveClassSectionPresenting,
              child: const Icon(
                Icons.screen_share_outlined,
                size: 16,
                color: LivePeopleSheet._presenting,
              ),
            ),
            const Gap(6),
          ],
          Tooltip(
            message: person.isCameraOn
                ? l10n.liveClassCameraIsOn
                : l10n.liveClassCameraIsOff,
            child: Icon(
              person.isCameraOn ? Icons.videocam_outlined : Icons.videocam_off,
              size: 16,
              color: person.isCameraOn ? Colors.white54 : Colors.white24,
            ),
          ),
          const Gap(6),
          Tooltip(
            message: person.isMicOn
                ? l10n.liveClassMicIsOn
                : l10n.liveClassMuted,
            child: Icon(
              person.isMicOn ? Icons.mic_none : Icons.mic_off,
              size: 16,
              color: person.isMicOn ? Colors.white54 : LivePeopleSheet._muted,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
    child: Text('·', style: TextStyle(color: Colors.white24, fontSize: 10)),
  );

  static String? _qualityLabel(BuildContext context, ConnectionQuality q) {
    final l10n = context.l10n;
    return switch (q) {
      ConnectionQuality.excellent => l10n.liveClassConnectionExcellent,
      ConnectionQuality.good => l10n.liveClassConnectionGood,
      ConnectionQuality.poor => l10n.liveClassConnectionPoor,
      ConnectionQuality.lost => l10n.liveClassConnectionLost,
      ConnectionQuality.unknown => null,
    };
  }

  static Color _qualityColor(ConnectionQuality q) => switch (q) {
    ConnectionQuality.excellent => const Color(0xFF22C55E),
    ConnectionQuality.good => const Color(0xFF84CC16),
    ConnectionQuality.poor => const Color(0xFFF59E0B),
    ConnectionQuality.lost => const Color(0xFFEF4444),
    ConnectionQuality.unknown => Colors.white24,
  };
}

class _Avatar extends StatelessWidget {
  const new({required this.person});

  final LivePerson person;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    final initials = person.initials;
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LivePeopleSheet._avatarColors[person.colorIndex],
        shape: BoxShape.circle,
        border: person.isSpeaking
            ? Border.all(color: LivePeopleSheet._speaking, width: 2)
            : null,
      ),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: context.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const new(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSpacing.r4),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
