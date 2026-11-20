import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:lengoal/core/core.dart';

enum ChatQuoteKind {
  text('💬'),
  image('📷'),
  file('📄');

  const ChatQuoteKind(this.mark);

  final String mark;

  static ChatQuoteKind? fromMark(String mark) =>
      values.where((k) => k.mark == mark).firstOrNull;
}

class ChatReplyQuote {
  const new({
    required this.name,
    required this.kind,
    required this.label,
    required this.body,
  });

  final String name;
  final ChatQuoteKind kind;
  final String label;
  final String body;

  static const int maxSnippet = 80;

  static final RegExp _pattern = RegExp(
    '^@([^:\\n·]{1,60}) · (💬|📷|📄) ([^:\\n]{1,120}):[ ]?',
  );

  static ChatReplyQuote? parse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) return null;
    final kind = ChatQuoteKind.fromMark(match.group(2)!);
    if (kind == null) return null;
    return ChatReplyQuote(
      name: match.group(1)!.trim(),
      kind: kind,
      label: match.group(3)!.trim(),
      body: text.substring(match.end),
    );
  }

  static String compose({
    required String name,
    required ChatQuoteKind kind,
    required String label,
    required String body,
  }) {
    var safeLabel = label.replaceAll(RegExp(r'[:\n]'), ' ');
    safeLabel = safeLabel.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (safeLabel.length > maxSnippet) {
      safeLabel = '${safeLabel.substring(0, maxSnippet).trimRight()}…';
    }
    return '@$name · ${kind.mark} $safeLabel: $body';
  }
}

class ChatMessageText extends StatefulWidget {
  const new({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  static final RegExp mentionPattern = RegExp(r'^@([^:\n]{1,60}):');
  static final RegExp _linkPattern = RegExp(
    r'(https?:\/\/[^\s]+|www\.[^\s]+)',
    caseSensitive: false,
  );

  static String withoutMention(String text) {
    final quote = ChatReplyQuote.parse(text);
    if (quote != null) return quote.body.trimLeft();
    return text.replaceFirst(mentionPattern, '').trimLeft();
  }

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
  ChatReplyQuote? _quote;
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
    final quote = ChatReplyQuote.parse(widget.text);
    _quote = quote;
    var rest = quote?.body ?? widget.text;
    if (quote == null) {
      final mention = ChatMessageText.mentionPattern.firstMatch(rest);
      if (mention != null) {
        segments.add(_Segment(mention.group(0)!, bold: true));
        rest = rest.substring(mention.end);
      }
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
    final text = Text.rich(
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
    final quote = _quote;
    if (quote == null) return text;
    final hasBody = _segments.any((s) => s.text.trim().isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ChatQuoteCard(
          name: quote.name,
          label: quote.label,
          kind: quote.kind,
          color: widget.color,
        ),
        if (hasBody) ...[const Gap(AppSpacing.s8), text],
      ],
    );
  }
}

class ChatQuoteCard extends StatelessWidget {
  const new({
    required this.name,
    required this.label,
    required this.kind,
    required this.color,
    super.key,
    this.thumbnail,
  });

  final String name;
  final String label;
  final ChatQuoteKind kind;
  final Color color;
  final Widget? thumbnail;

  @override
  Widget build(BuildContext context) {
    final small = context.textTheme.bodySmall;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.r4),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (thumbnail != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.r4),
              child: SizedBox.square(dimension: 36, child: thumbnail),
            ),
            const Gap(AppSpacing.s8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: small?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kind != ChatQuoteKind.text) ...[
                      Icon(
                        kind == ChatQuoteKind.image
                            ? Icons.photo_outlined
                            : Icons.insert_drive_file_outlined,
                        size: 14,
                        color: color.withValues(alpha: 0.85),
                      ),
                      const Gap(AppSpacing.s4),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: kind == ChatQuoteKind.text ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: small?.copyWith(
                          color: color.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
