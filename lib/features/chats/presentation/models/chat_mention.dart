import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

class ChatMember extends Equatable {
  const new({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  List<Object?> get props => [name, photoUrl];
}

class ChatMentionQuery extends Equatable {
  const new({required this.start, required this.query});

  static const String everyone = 'all';
  static const int maxLength = 40;

  final int start;
  final String query;

  static final RegExp _space = RegExp(r'\s');

  static ChatMentionQuery? detect(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) return null;
    final text = value.text;
    final cursor = selection.baseOffset;
    if (cursor <= 0 || cursor > text.length) return null;
    final at = text.lastIndexOf('@', cursor - 1);
    if (at < 0) return null;
    if (at > 0 && !_space.hasMatch(text[at - 1])) return null;
    final query = text.substring(at + 1, cursor);
    if (query.length > maxLength ||
        query.contains('\n') ||
        query.startsWith(' ') ||
        query.contains('  ')) {
      return null;
    }
    return ChatMentionQuery(start: at, query: query);
  }

  bool matches(String name) {
    final q = query.toLowerCase();
    if (q.isEmpty) return true;
    final n = name.toLowerCase();
    if (n.startsWith(q)) return true;
    if (q.contains(' ')) return false;
    return n.split(_space).any((word) => word.startsWith(q));
  }

  TextEditingValue apply(TextEditingValue value, String name) {
    final end = value.selection.baseOffset;
    var after = value.text.substring(end);
    if (after.startsWith(' ')) after = after.substring(1);
    final insert = '@$name ';
    return TextEditingValue(
      text: value.text.substring(0, start) + insert + after,
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
  }

  @override
  List<Object?> get props => [start, query];
}

RegExp chatMentionPattern(Iterable<String> names) {
  final unique = {
    for (final name in names)
      if (name.trim().isNotEmpty) name.trim(),
  }.toList()..sort((a, b) => b.length.compareTo(a.length));
  final options = [...unique.map(RegExp.escape), ChatMentionQuery.everyone];
  return RegExp(
    '@(?:${options.join('|')})(?![\\p{L}\\p{N}_])',
    caseSensitive: false,
    unicode: true,
  );
}
