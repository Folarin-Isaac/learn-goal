import 'dart:convert';

// Hand raises and emoji reactions travel as JSON data messages on the
// LiveKit room (reliable, no topic). The shapes below copy the web app's
// live-class code exactly, so the web and the app see each other's hands
// and reactions:
//   {kind: raise_hand, identity, name, isRaised, timestamp}
//   {kind: lower_hand, targetIdentity}      (educator lowers one hand)
//   {kind: lower_all_hands}
//   {kind: hand_state_query}                (sent on join; anyone with a
//                                            raised hand re-announces it)
//   {kind: emoji_reaction, reactionId, emoji, participantName}

enum LiveReaction {
  love('love', '❤️'),
  clap('clap', '👏'),
  celebrate('celebrate', '🎉'),
  laugh('laugh', '😂'),
  sad('sad', '😢'),
  thumbsUp('thumbsup', '👍'),
  thumbsDown('thumbsdown', '👎'),
  thinking('thinking', '🤔'),
  wave('wave', '👋');

  new(this.id, this.emoji);

  final String id;
  final String emoji;
}

sealed class LiveSignal {
  const new();

  static LiveSignal? decode(List<int> data) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(data));
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final json = decoded;
    String text(String key) {
      final value = json[key];
      return value is String ? value : '';
    }

    switch (json['kind']) {
      case 'raise_hand':
        final identity = text('identity');
        if (identity.isEmpty) return null;
        final timestamp = json['timestamp'];
        return RaiseHandSignal(
          identity: identity,
          name: text('name'),
          isRaised: json['isRaised'] == true,
          timestamp: timestamp is num ? timestamp.toInt() : 0,
        );
      case 'lower_hand':
        final target = text('targetIdentity');
        return target.isEmpty ? null : LowerHandSignal(target);
      case 'lower_all_hands':
        return const LowerAllHandsSignal();
      case 'hand_state_query':
        return const HandStateQuerySignal();
      case 'emoji_reaction':
        final emoji = text('emoji');
        final id = text('reactionId');
        if (emoji.isEmpty || id == 'raised') return null;
        return ReactionSignal(
          reactionId: id,
          emoji: emoji,
          participantName: text('participantName'),
        );
    }
    return null;
  }

  Map<String, Object?> toJson();

  List<int> encode() => utf8.encode(jsonEncode(toJson()));
}

class RaiseHandSignal extends LiveSignal {
  const new({
    required this.identity,
    required this.name,
    required this.isRaised,
    required this.timestamp,
  });

  final String identity;
  final String name;
  final bool isRaised;
  final int timestamp;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'raise_hand',
    'identity': identity,
    'name': name,
    'isRaised': isRaised,
    'timestamp': timestamp,
  };
}

class LowerHandSignal extends LiveSignal {
  const new(this.targetIdentity);

  final String targetIdentity;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'lower_hand',
    'targetIdentity': targetIdentity,
  };
}

class LowerAllHandsSignal extends LiveSignal {
  const new();

  @override
  Map<String, Object?> toJson() => {'kind': 'lower_all_hands'};
}

class HandStateQuerySignal extends LiveSignal {
  const new();

  @override
  Map<String, Object?> toJson() => {'kind': 'hand_state_query'};
}

class ReactionSignal extends LiveSignal {
  const new({
    required this.reactionId,
    required this.emoji,
    required this.participantName,
  });

  final String reactionId;
  final String emoji;
  final String participantName;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'emoji_reaction',
    'reactionId': reactionId,
    'emoji': emoji,
    'participantName': participantName,
  };
}

// Something the room shows briefly: a floating emoji or a "raised their
// hand" toast.
sealed class LiveRoomMoment {
  const new();
}

class ReactionMoment extends LiveRoomMoment {
  const new({required this.emoji, required this.name});

  final String emoji;
  final String name;
}

class HandRaisedMoment extends LiveRoomMoment {
  const new(this.name);

  final String name;
}

class HandLoweredMoment extends LiveRoomMoment {
  const new();
}
