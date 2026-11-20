import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:lengoal/core/core.dart';

class ChatMessageText extends StatefulWidget {
  const new({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  static final RegExp mentionPattern = RegExp(r'^@([^:\n]{1,60}):');
  static final RegExp _linkPattern = RegExp(
    r'(https?:\/\/[^\s]+|www\.[^\s]+)',
    caseSensitive: false,
  );

  static String withoutMention(String text) =>
      text.replaceFirst(mentionPattern, '').trimLeft();

  @override
  State<ChatMessageText> createState() => _ChatMessageTextState();
}

class _Segment {
  const new(this.text, {this.url, this.bold = false});

  final String text;
  final String? url;
  final bool bold;
}

class _ChatMessageTextState extends State<ChatMessageText> {
  List<_Segment> _segments = const [];
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(ChatMessageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _parse();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  void _parse() {
    _disposeRecognizers();
    final segments = <_Segment>[];
    var rest = widget.text;
    final mention = ChatMessageText.mentionPattern.firstMatch(rest);
    if (mention != null) {
      segments.add(_Segment(mention.group(0)!, bold: true));
      rest = rest.substring(mention.end);
    }
    var index = 0;
    for (final match in ChatMessageText._linkPattern.allMatches(rest)) {
      if (match.start > index) {
        segments.add(_Segment(rest.substring(index, match.start)));
      }
      final raw = _trimTrailingPunctuation(match.group(0)!);
      segments.add(_Segment(raw, url: raw));
      final trailing = match.group(0)!.substring(raw.length);
      if (trailing.isNotEmpty) segments.add(_Segment(trailing));
      index = match.end;
    }
    if (index < rest.length) segments.add(_Segment(rest.substring(index)));
    _segments = segments;
  }

  static String _trimTrailingPunctuation(String url) {
    var end = url.length;
    while (end > 0 && '.,!?;:)]\'"'.contains(url[end - 1])) {
      end--;
    }
    return url.substring(0, end);
  }

  TapGestureRecognizer _recognizerFor(String url) {
    final target = url.startsWith(RegExp('https?://', caseSensitive: false))
        ? url
        : 'https://$url';
    final recognizer = TapGestureRecognizer()
      ..onTap = () => unawaited(openExternalUrl(target));
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    final base = context.textTheme.bodyMedium?.copyWith(color: widget.color);
    _disposeRecognizers();
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final s in _segments)
            if (s.url != null)
              TextSpan(
                text: s.text,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: widget.color,
                ),
                recognizer: _recognizerFor(s.url!),
              )
            else
              TextSpan(
                text: s.text,
                style: s.bold
                    ? const TextStyle(fontWeight: FontWeight.w700)
                    : null,
              ),
        ],
      ),
    );
  }
}
