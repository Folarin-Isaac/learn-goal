import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';

// ClassDiscussion message DTO, shared by the post list and get-replies.
DiscussionPost discussionPostFromJson(Map<String, dynamic> json) {
  return DiscussionPost(
    id: json['id'] as String? ?? '',
    parentPostId: _nonEmpty(json['parentPostId']),
    senderUserId: json['senderUserId'] as String?,
    senderName: json['senderName'] as String? ?? '',
    content: json['content'] as String? ?? '',
    createdAt: _parseUtc(json['createdAt'] as String?),
    role: DiscussionUserRole.fromCode((json['userType'] as num?)?.toInt()),
    isEdited: json['isEdited'] as bool? ?? false,
    likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  );
}

String? _nonEmpty(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

// createdAt arrives without a zone designator; the backend stores UTC, so
// it's read as UTC rather than device-local time.
DateTime _parseUtc(String? value) {
  if (value == null || value.isEmpty) return DateTime.now();
  final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
  return DateTime.tryParse(hasZone ? value : '${value}Z')?.toLocal() ??
      DateTime.now();
}
