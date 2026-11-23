import 'package:livekit_client/livekit_client.dart';

// One row of the room's People list. Mirrors the web's participant panel:
// same fields, same sort order, same search and sections.
class LivePerson {
  const new({
    required this.identity,
    required this.name,
    required this.isLocal,
    required this.isHost,
    required this.isHandRaised,
    required this.isMicOn,
    required this.isCameraOn,
    required this.isPresenting,
    required this.isSpeaking,
    this.quality = ConnectionQuality.unknown,
  });

  factory from(
    Participant participant, {
    required bool isLocal,
    required bool isHost,
    required bool isHandRaised,
  }) {
    final name = participant.name.trim().isNotEmpty
        ? participant.name.trim()
        : participant.identity.isNotEmpty
        ? participant.identity
        : 'Guest';
    return LivePerson(
      identity: participant.identity,
      name: name,
      isLocal: isLocal,
      isHost: isHost,
      isHandRaised: isHandRaised,
      isMicOn: participant.isMicrophoneEnabled(),
      isCameraOn: participant.isCameraEnabled(),
      isPresenting: participant.isScreenShareEnabled(),
      isSpeaking: participant.isSpeaking,
      quality: participant.connectionQuality,
    );
  }

  final String identity;
  final String name;
  final bool isLocal;
  final bool isHost;
  final bool isHandRaised;
  final bool isMicOn;
  final bool isCameraOn;
  final bool isPresenting;
  final bool isSpeaking;
  final ConnectionQuality quality;

  // First letters of up to the first two words, as the web shows them.
  String get initials {
    final letters = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w.substring(0, 1))
        .join()
        .toUpperCase();
    return letters.length <= 2 ? letters : letters.substring(0, 2);
  }

  // The web picks the avatar colour from the sum of the identity's
  // character codes, so a person has the same colour on both.
  int get colorIndex =>
      identity.codeUnits.fold<int>(0, (sum, c) => sum + c) % paletteSize;

  static const int paletteSize = 8;
}

enum LivePeopleSection { raisedHands, presenting, speaking, rest }

class LivePeopleGroup {
  const new(this.section, this.people);

  final LivePeopleSection section;
  final List<LivePerson> people;
}

// Local first, then the host, raised hands, presenters, speakers, then by
// name (same order as the web).
List<LivePerson> sortPeople(Iterable<LivePerson> people) {
  int flag({required bool a, required bool b}) => a == b ? 0 : (a ? -1 : 1);
  return people.toList()..sort((a, b) {
    for (final c in [
      flag(a: a.isLocal, b: b.isLocal),
      flag(a: a.isHost, b: b.isHost),
      flag(a: a.isHandRaised, b: b.isHandRaised),
      flag(a: a.isPresenting, b: b.isPresenting),
      flag(a: a.isSpeaking, b: b.isSpeaking),
    ]) {
      if (c != 0) return c;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
}

// Filters by name or identity, then splits into the web's sections. Each
// person appears once; empty sections are left out.
List<LivePeopleGroup> groupPeople(List<LivePerson> sorted, String query) {
  final q = query.trim().toLowerCase();
  final matches = q.isEmpty
      ? sorted
      : sorted
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.identity.toLowerCase().contains(q),
            )
            .toList();
  final raised = matches.where((p) => p.isHandRaised).toList();
  final presenting = matches
      .where((p) => !p.isHandRaised && p.isPresenting)
      .toList();
  final speaking = matches
      .where((p) => !p.isHandRaised && !p.isPresenting && p.isSpeaking)
      .toList();
  final rest = matches
      .where((p) => !p.isHandRaised && !p.isPresenting && !p.isSpeaking)
      .toList();
  return [
    if (raised.isNotEmpty)
      LivePeopleGroup(LivePeopleSection.raisedHands, raised),
    if (presenting.isNotEmpty)
      LivePeopleGroup(LivePeopleSection.presenting, presenting),
    if (speaking.isNotEmpty)
      LivePeopleGroup(LivePeopleSection.speaking, speaking),
    if (rest.isNotEmpty) LivePeopleGroup(LivePeopleSection.rest, rest),
  ];
}
